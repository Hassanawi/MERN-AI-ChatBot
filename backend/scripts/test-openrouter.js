/*
Simple script to test OpenRouter/OpenAI-compatible endpoints directly with your API key.
Run from the `backend` folder with Node 18+.

PowerShell example:
$env:OPEN_AI_SECRET="sk-..."
node .\scripts\test-openrouter.js

It will:
- Try GET /v1/models
- For a short list of candidate models, try POST /v1/chat/completions with a short test message
- Print response status and body (truncated for large bodies)
*/

import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

// If OPEN_AI_SECRET isn't set in the environment, try to load backend/.env automatically
if (!process.env.OPEN_AI_SECRET) {
    const envPath = path.resolve(__dirname, '..', '.env');
    if (fs.existsSync(envPath)) {
        const text = fs.readFileSync(envPath, 'utf8');
        for (const line of text.split(/\r?\n/)) {
            const m = line.match(/^\s*([A-Za-z0-9_]+)=(.*)$/);
            if (m) {
                const key = m[1];
                let val = m[2] || '';
                // remove surrounding quotes
                if ((val.startsWith('"') && val.endsWith('"')) || (val.startsWith("'") && val.endsWith("'"))) {
                    val = val.slice(1, -1);
                }
                if (!process.env[key]) process.env[key] = val;
            }
        }
        console.log('Loaded environment variables from', envPath);
    }
}

const baseCandidates = [
    process.env.OPENROUTER_BASE || 'https://api.openrouter.ai/v1',
    'https://openrouter.ai/v1'
].filter(Boolean);

const headers = {
    'Content-Type': 'application/json',
    'Authorization': `Bearer ${process.env.OPEN_AI_SECRET || ''}`,
};

function trunc(str, n = 4000) {
    if (!str) return str;
    if (typeof str !== 'string') return JSON.stringify(str).slice(0, n);
    return str.length > n ? str.slice(0, n) + `\n... (truncated, total ${str.length} chars)` : str;
}

async function tryModelsList(base) {
    const url = base.replace(/\/$/, '') + '/models';
    console.log('\n==> Models list request to:', url);
    try {
        const res = await fetch(url, { method: 'GET', headers });
        const text = await res.text();
        console.log('Status:', res.status);
        console.log('Body (truncated):\n', trunc(text, 8000));
        let json;
        try { json = JSON.parse(text); } catch (e) { json = null; }
        return { status: res.status, bodyText: text, bodyJson: json };
    } catch (err) {
        console.error('Error fetching models list:', err);
        return { error: err };
    }
}

async function tryChatCompletion(base, model) {
    const url = base.replace(/\/$/, '') + '/chat/completions';
    console.log('\n==> Chat completion request to:', url, ' model=', model);
    const body = {
        model,
        messages: [{ role: 'user', content: 'Say hello and identify the model you used in one short sentence.' }],
        temperature: 0.2,
        max_tokens: 200,
    };
    try {
        const res = await fetch(url, { method: 'POST', headers, body: JSON.stringify(body) });
        const text = await res.text();
        console.log('Status:', res.status);
        console.log('Body (truncated):\n', trunc(text, 8000));
        let json;
        try { json = JSON.parse(text); } catch (e) { json = null; }
        return { status: res.status, bodyText: text, bodyJson: json };
    } catch (err) {
        console.error('Error calling chat completions:', err);
        return { error: err };
    }
}

(async () => {
    if (!process.env.OPEN_AI_SECRET) {
        console.error('Please set OPEN_AI_SECRET in env before running this script. Example:');
        console.error('  $env:OPEN_AI_SECRET="sk-..."');
        process.exit(1);
    }

    for (const base of baseCandidates) {
        const modelsRes = await tryModelsList(base);
        if (modelsRes && modelsRes.bodyJson && Array.isArray(modelsRes.bodyJson.models)) {
            console.log('\nFound models array. Listing top 10 ids:');
            const ids = modelsRes.bodyJson.models.slice(0, 30).map(m => m.id || m.name || JSON.stringify(m)).slice(0, 10);
            console.log(ids.join('\n'));
        }

        // Try a short set of candidate models (from your .env and some commons)
        const candidateModels = [
            process.env.OPENROUTER_MODEL,
            'google/gemini-2.0-flash-exp:free',
            'google/gemma-3-27b:free',
            'google/gemma-3-12b:free',
            'google/gemma-3-4b:free',
            'gpt-3.5-turbo',
            'gpt-3.5-turbo-16k'
        ].filter(Boolean);

        for (const model of candidateModels) {
            const chatRes = await tryChatCompletion(base, model);
            // If we got a JSON response with choices and a message, stop early
            const json = chatRes.bodyJson;
            if (json && Array.isArray(json.choices) && json.choices.length > 0) {
                console.log('\nReceived choices for model', model, ' — sample:');
                try {
                    console.log(JSON.stringify(json.choices[0], null, 2).slice(0, 4000));
                } catch (e) { console.log('Could not stringify choice'); }
            }
        }
    }

    console.log('\nDone. Review the printed outputs above for provider responses.');
})();
