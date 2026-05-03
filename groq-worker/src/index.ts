type GroqResponse = {
  choices?: {
    message?: {
      content?: string;
    };
  }[];
};

type RequestBody = {
  profileText?: string;
};

type ProfileSchema = {
  name: string;
  email: string;
  headline: string;
  recent_company: string;
  recent_role: string;
  experience_years: string;
  skills: string[];
};

// ✅ Always return this shape
function normalizeProfile(data: any): ProfileSchema {
  return {
    name: typeof data?.name === "string" ? data.name : "",
    email: typeof data?.email === "string" ? data.email : "",
    headline: typeof data?.headline === "string" ? data.headline : "",
    recent_company: typeof data?.recent_company === "string" ? data.recent_company : "",
    recent_role: typeof data?.recent_role === "string" ? data.recent_role : "",
    experience_years: typeof data?.experience_years === "string" ? data.experience_years : "",
    skills: Array.isArray(data?.skills)
      ? data.skills.filter((s: any) => typeof s === "string")
      : [],
  };
}

export default {
  async fetch(request: Request, env: any): Promise<Response> {
    if (request.method !== "POST") {
      return new Response("Method not allowed", { status: 405 });
    }

    try {
      const body = (await request.json()) as RequestBody;
      const profileText = body.profileText;

      if (!profileText) {
        return new Response(
          JSON.stringify({ error: "profileText is required" }),
          { status: 400, headers: { "Content-Type": "application/json" } }
        );
      }

      const groqRes = await fetch(
        "https://api.groq.com/openai/v1/chat/completions",
        {
          method: "POST",
          headers: {
            Authorization: `Bearer ${env.GROQ_API_KEY}`,
            "Content-Type": "application/json",
          },
          body: JSON.stringify({
            model: "llama-3.3-70b-versatile",
            temperature: 0.1, // 🔥 reduce randomness
            max_tokens: 200,
            messages: [
              {
                role: "system",
                content: `
You are a strict data extraction engine.

IMPORTANT:
- Return ONLY raw JSON (no markdown, no text)
- Do NOT wrap in \`\`\`
- Do NOT explain anything
- If unsure, leave fields empty

SCHEMA:
{
  "name": "",
  "email": "",
  "headline": "",
  "recent_company": "",
  "recent_role": "",
  "experience_years": "",
  "skills": []
}
`
              },
              {
                role: "user",
                content: profileText,
              },
            ],
          }),
        }
      );

      const data = (await groqRes.json()) as GroqResponse;

      let content = data?.choices?.[0]?.message?.content ?? "";

      // Clean AI formatting issues
      content = content.replace(/```json/g, "").replace(/```/g, "").trim();

      let parsed: any = {};

      try {
        parsed = JSON.parse(content);
      } catch {
        // If parsing fails → fallback to empty object
        parsed = {};
      }

      // ✅ Enforce schema ALWAYS
      const finalData = normalizeProfile(parsed);

      return new Response(JSON.stringify(finalData), {
        headers: { "Content-Type": "application/json" },
      });

    } catch (error: any) {
      return new Response(
        JSON.stringify({
          error: "Internal server error",
          details: error?.message || "unknown",
        }),
        { status: 500, headers: { "Content-Type": "application/json" } }
      );
    }
  },
};