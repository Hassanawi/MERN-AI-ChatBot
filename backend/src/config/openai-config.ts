import { Configuration } from "openai";

export const configureOpenAI = () => {
  const apiKey = process.env.OPEN_AI_SECRET;
  const org = process.env.OPENAI_ORAGANIZATION_ID;
  if (!apiKey || apiKey.trim() === "") {
    throw new Error("Missing OpenAI API key. Set OPEN_AI_SECRET in your environment.");
  }
  
  // Support using OpenRouter or other OpenAI-compatible endpoints
  const base = process.env.OPENROUTER_BASE;
  
  const config = new Configuration({
    apiKey,
    organization: org,
    basePath: base && base.trim() !== "" ? base : undefined,
  });

  return config;
};

// Return the base path to manually set on OpenAIApi if needed
export const getBasePath = () => {
  const base = process.env.OPENROUTER_BASE;
  return base && base.trim() !== "" ? base : undefined;
};
