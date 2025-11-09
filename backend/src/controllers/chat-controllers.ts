import { NextFunction, Request, Response } from "express";
import User from "../models/User.js";
import { configureOpenAI, getBasePath } from "../config/openai-config.js";
import { OpenAIApi, ChatCompletionRequestMessage } from "openai";
export const generateChatCompletion = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  const { message } = req.body;
  try {
    const user = await User.findById(res.locals.jwtData.id);
    if (!user)
      return res
        .status(401)
        .json({ message: "User not registered OR Token malfunctioned" });
    // grab chats of user
    const chats = user.chats.map(({ role, content }) => ({
      role,
      content,
    })) as ChatCompletionRequestMessage[];
    chats.push({ content: message, role: "user" });
    user.chats.push({ content: message, role: "user" });

    // send all chats with new one to openAI API
    const config = configureOpenAI();
    const openai = new OpenAIApi(config);
    
    // For openai v3, manually override basePath after construction if using OpenRouter
    const basePath = getBasePath();
    if (basePath) {
      // @ts-ignore - basePath exists but TypeScript might not expose it
      openai.basePath = basePath;
    }
    
    // allow selecting model via env var (supports OpenAI or OpenRouter models)
    // If the configured model is not available for the current key, try a short list of fallbacks
    const preferredModel = process.env.OPENAI_MODEL || process.env.OPENROUTER_MODEL || "gpt-3.5-turbo";
    const candidateModels = Array.from(new Set([
      preferredModel,
      // common OpenAI-compatible models (may or may not be available via OpenRouter)
      "gpt-3.5-turbo",
      "gpt-3.5-turbo-16k",
      // community / smaller models often exposed by OpenRouter providers (try a few common ids)
      "mistral/mistral-7b-instruct",
      "openassistant/oa-1",
      "oasst/oasst-sft-6-llama-2048",
      // Google / Gemma / Gemini community models (free) suggested by user
      // I used reasonable OpenRouter-style ids — adjust if your provider reports different ids in the models list
      "google/gemini-2.0-flash-exp:free",
  // AtlasCloud / open-source model the user reported
  "openai/gpt-oss-20b:free",
      "google/gemma-3-27b:free",
      "google/gemma-3-12b:free",
      "google/gemma-3-4b:free",
    ].filter(Boolean)));

    let lastError: any = null;
    // helper to extract assistant text from various provider response shapes
    const extractAssistantMessage = (data: any): string | { role: string; content: string } | null => {
      try {
        if (!data) return null;
        // Common OpenAI shape: choices[0].message.content or choices[0].message
        const choice = data?.choices?.[0];
        if (choice) {
          // Chat-style
          if (choice.message && (choice.message.content || choice.message.role)) {
            const content = choice.message.content || (typeof choice.message === 'string' ? choice.message : undefined);
            if (content) return { role: choice.message.role || 'assistant', content };
          }
          // older/alternative: choices[0].text
          if (choice.text) return { role: 'assistant', content: choice.text };
        }
        // Some providers return top-level text fields
        if (typeof data.output_text === 'string' && data.output_text.trim()) return data.output_text;
        if (typeof data.text === 'string' && data.text.trim()) return data.text;
        if (typeof data.generated_text === 'string' && data.generated_text.trim()) return data.generated_text;
        // OpenRouter / other shapes: output -> [{ content: [{ type: 'output_text'|'text', text: '...' }] }]
        const out = data?.output ?? data?.outputs ?? null;
        if (Array.isArray(out) && out.length > 0) {
          const first = out[0];
          // nested content
          const c = first?.content ?? first?.data ?? first;
          if (Array.isArray(c)) {
            // find text-like entry
            for (const item of c) {
              if (item?.text) return item.text;
              if (item?.type && (item.type === 'output_text' || item.type === 'text') && item?.text) return item.text;
              if (typeof item === 'string' && item.trim()) return item;
            }
          }
          if (typeof c === 'string' && c.trim()) return c;
        }
        return null;
      } catch (e) {
        console.error('Error extracting assistant message:', e);
        return null;
      }
    };
    for (const model of candidateModels) {
      try {
        console.log(`Trying model: ${model}`);
        const chatResponse = await openai.createChatCompletion({ model, messages: chats });
        const extracted = extractAssistantMessage(chatResponse.data);
        if (extracted) {
          if (typeof extracted === 'string') {
            user.chats.push({ role: 'assistant', content: extracted } as any);
          } else {
            user.chats.push(extracted as any);
          }
          await user.save();
          return res.status(200).json({ chats: user.chats });
        }
        // No assistant message returned — record and try next model
        console.warn(`Model ${model} returned no assistant message`, chatResponse.data);
        lastError = new Error('No assistant message returned');
      } catch (err: any) {
        lastError = err;
        console.error(`Error from model ${model}:`, err?.message || err);
        // If the provider returned a response (axios / underlying fetch), log status and body for debugging
        try {
          const resp = err?.response;
          if (resp) {
            console.error("Provider response status:", resp.status);
            // sometimes OpenRouter returns HTML pages for missing models — log first part only
            const respData = typeof resp.data === "string" ? resp.data.slice(0, 2000) : resp.data;
            console.error("Provider response data (truncated):", respData);
            // If this model was explicitly reported as not found, try the next candidate
            const bodyStr = typeof resp.data === "string" ? resp.data : JSON.stringify(resp.data || "");
            if (resp.status === 404 || /Model Not Found/i.test(bodyStr)) {
              console.info(`Model ${model} not available for this key — trying next model.`);
              continue;
            }
          }
        } catch (logErr) {
          console.error("Error while logging provider response:", logErr);
        }
        // For other errors, continue to next candidate model
        continue;
      }
    }

    // If we reach here, none of the candidate models produced a response
    console.error("All candidate models failed. Last error:", lastError?.message || lastError);
    // Optional fallback for local development: return a canned assistant response
    if (!process.env.OPEN_AI_STRICT) {
      const fallback = { role: "assistant", content: "(local fallback) Sorry, the model is unavailable right now. Please try again later." };
      user.chats.push(fallback as any);
      await user.save();
      return res.status(200).json({ chats: user.chats });
    }
    return res.status(500).json({ message: "Something went wrong", cause: lastError?.message || lastError });
  } catch (error) {
    console.log(error);
    return res.status(500).json({ message: "Something went wrong" });
  }
};

export const sendChatsToUser = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    //user token check
    const user = await User.findById(res.locals.jwtData.id);
    if (!user) {
      return res.status(401).send("User not registered OR Token malfunctioned");
    }
    if (user._id.toString() !== res.locals.jwtData.id) {
      return res.status(401).send("Permissions didn't match");
    }
    return res.status(200).json({ message: "OK", chats: user.chats });
  } catch (error) {
    console.log(error);
    return res.status(200).json({ message: "ERROR", cause: error.message });
  }
};

export const deleteChats = async (
  req: Request,
  res: Response,
  next: NextFunction
) => {
  try {
    //user token check
    const user = await User.findById(res.locals.jwtData.id);
    if (!user) {
      return res.status(401).send("User not registered OR Token malfunctioned");
    }
    if (user._id.toString() !== res.locals.jwtData.id) {
      return res.status(401).send("Permissions didn't match");
    }
    //@ts-ignore
    user.chats = [];
    await user.save();
    return res.status(200).json({ message: "OK" });
  } catch (error) {
    console.log(error);
    return res.status(200).json({ message: "ERROR", cause: error.message });
  }
};
