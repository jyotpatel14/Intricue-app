// type GroqResponse = {
// 	choices?: {
// 		message?: {
// 			content?: string;
// 		};
// 	}[];
// };

// type ProfileSchema = {
// 	name: string;
// 	email: string;
// 	headline: string;
// 	recent_company: string;
// 	recent_role: string;
// 	experience_years: string;
// 	skills: string[];
// };

// function corsHeaders() {
// 	return {
// 		"Access-Control-Allow-Origin": "*",
// 		"Access-Control-Allow-Methods": "POST, OPTIONS",
// 		"Access-Control-Allow-Headers": "Content-Type, Accept",
// 		"Access-Control-Max-Age": "86400",
// 	};
// }

// function normalizeProfile(data: any): ProfileSchema {
// 	return {
// 		name: typeof data?.name === "string" ? data.name.trim() : "",
// 		email: typeof data?.email === "string" ? data.email.trim() : "",
// 		headline: typeof data?.headline === "string" ? data.headline.trim() : "",
// 		recent_company:
// 			typeof data?.recent_company === "string"
// 				? data.recent_company.trim()
// 				: "",
// 		recent_role:
// 			typeof data?.recent_role === "string" ? data.recent_role.trim() : "",
// 		experience_years:
// 			typeof data?.experience_years === "string"
// 				? data.experience_years.trim()
// 				: "",
// 		skills: Array.isArray(data?.skills)
// 			? data.skills.filter((s: any) => typeof s === "string")
// 			: [],
// 	};
// }

// // ✅ THE REAL FIX:
// // If the client uses JSON.stringify() correctly, quotes inside profileText
// // are already escaped as \" — they are never the problem.
// // The actual culprits are raw control characters (real \n, \r, \t bytes)
// // that sneak in when the client builds JSON via string interpolation.
// // Stripping ALL control chars (0x00-0x1F) from the raw body is safe
// // because JSON structural characters are never in that range.
// // As a last resort, we regex-extract profileText directly from the raw body.
// function extractProfileText(rawBody: string): string | null {
// 	// Attempt 1: strip control chars, then JSON.parse
// 	const cleaned = rawBody.replace(/[\x00-\x1F\x7F]/g, " ");
// 	try {
// 		const parsed = JSON.parse(cleaned);
// 		if (typeof parsed?.profileText === "string") {
// 			return parsed.profileText;
// 		}
// 	} catch (e) {
// 		console.log("❌ JSON.parse failed after strip: " + e);
// 	}

// 	// Attempt 2: regex extract profileText value directly from raw body
// 	// Handles completely broken JSON where the value itself has unescaped quotes
// 	const match = rawBody.match(/"profileText"\s*:\s*"([\s\S]*?)"\s*[,}]/);
// 	if (match) {
// 		return match[1]
// 			.replace(/\\n/g, "\n")
// 			.replace(/\\r/g, "")
// 			.replace(/\\t/g, " ")
// 			.replace(/\\"/g, '"');
// 	}

// 	return null;
// }

// export default {
// 	async fetch(request: Request, env: any): Promise<Response> {
// 		if (request.method === "OPTIONS") {
// 			return new Response(null, { headers: corsHeaders() });
// 		}

// 		if (request.method !== "POST") {
// 			return new Response("Method not allowed", {
// 				status: 405,
// 				headers: corsHeaders(),
// 			});
// 		}

// 		try {
// 			const rawBody = await request.text();
// 			console.log("📨 RAW BODY LENGTH: " + rawBody.length);

// 			let profileText = extractProfileText(rawBody);

// 			if (!profileText) {
// 				console.log("❌ Could not extract profileText");
// 				return new Response(
// 					JSON.stringify({ error: "profileText is required" }),
// 					{
// 						status: 400,
// 						headers: { "Content-Type": "application/json", ...corsHeaders() },
// 					}
// 				);
// 			}

// 			console.log("✅ profileText length: " + profileText.length);

// 			if (profileText.length > 4000) {
// 				profileText = profileText.substring(0, 4000);
// 			}

// 			const groqRes = await fetch(
// 				"https://api.groq.com/openai/v1/chat/completions",
// 				{
// 					method: "POST",
// 					headers: {
// 						Authorization: `Bearer ${env.GROQ_API_KEY}`,
// 						"Content-Type": "application/json",
// 					},
// 					body: JSON.stringify({
// 						model: "llama-3.3-70b-versatile",
// 						temperature: 0.1,
// 						max_tokens: 400,
// 						messages: [
// 							{
// 								role: "system",
// 								content: `You are a strict JSON extractor.

// CRITICAL RULES:
// - Output ONLY valid JSON
// - No markdown, no backticks
// - No explanation
// - No line breaks inside string values
// - If a field is unknown, return empty string or empty array

// Return EXACTLY this schema, nothing else:
// {"name":"","email":"","headline":"","recent_company":"","recent_role":"","experience_years":"","skills":[]}`,
// 							},
// 							{
// 								role: "user",
// 								content: profileText,
// 							},
// 						],
// 					}),
// 				}
// 			);

// 			const rawText = await groqRes.text();
// 			console.log("🔥 GROQ RAW: " + rawText);

// 			let data: GroqResponse = {};
// 			try {
// 				data = JSON.parse(rawText);
// 			} catch (e) {
// 				console.log("❌ Groq response not valid JSON: " + rawText);
// 			}

// 			let content = data?.choices?.[0]?.message?.content ?? "";
// 			console.log("🧠 AI CONTENT: " + content);

// 			// Clean any markdown or control chars from AI response
// 			content = content
// 				.replace(/```json/g, "")
// 				.replace(/```/g, "")
// 				.replace(/[\x00-\x1F\x7F]/g, " ")
// 				.trim();

// 			let parsed: any = {};

// 			try {
// 				parsed = JSON.parse(content);
// 				if (typeof parsed === "string") {
// 					parsed = JSON.parse(parsed);
// 				}
// 			} catch (e) {
// 				console.log("❌ First parse failed: " + content);
// 				try {
// 					const match = content.match(/\{[\s\S]*\}/);
// 					if (match) {
// 						parsed = JSON.parse(match[0]);
// 					}
// 				} catch (e2) {
// 					console.log("❌ Second parse failed, returning empty profile");
// 					parsed = {};
// 				}
// 			}

// 			const finalData = normalizeProfile(parsed);
// 			console.log("✅ FINAL: " + JSON.stringify(finalData));

// 			return new Response(JSON.stringify(finalData), {
// 				headers: {
// 					"Content-Type": "application/json",
// 					...corsHeaders(),
// 				},
// 			});
// 		} catch (error: any) {
// 			console.log("🔥 WORKER ERROR: " + (error?.message || error));

// 			return new Response(
// 				JSON.stringify({
// 					error: "Internal server error",
// 					details: error?.message || "unknown",
// 				}),
// 				{
// 					status: 500,
// 					headers: {
// 						"Content-Type": "application/json",
// 						...corsHeaders(),
// 					},
// 				}
// 			);
// 		}
// 	},
// };

type GroqResponse = {
	choices?: {
		message?: {
			content?: string;
		};
	}[];
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

function corsHeaders(): HeadersInit {
	return {
		"Access-Control-Allow-Origin": "*",
		"Access-Control-Allow-Methods": "POST, OPTIONS",
		"Access-Control-Allow-Headers": "Content-Type, Accept",
		"Access-Control-Max-Age": "86400",
	};
}

function normalizeProfile(data: any): ProfileSchema {
	return {
		name: typeof data?.name === "string" ? data.name.trim() : "",
		email: typeof data?.email === "string" ? data.email.trim() : "",
		headline: typeof data?.headline === "string" ? data.headline.trim() : "",
		recent_company:
			typeof data?.recent_company === "string" ? data.recent_company.trim() : "",
		recent_role:
			typeof data?.recent_role === "string" ? data.recent_role.trim() : "",
		experience_years:
			typeof data?.experience_years === "string" ? data.experience_years.trim() : "",
		skills: Array.isArray(data?.skills)
			? data.skills.filter((s: any) => typeof s === "string")
			: [],
	};
}

function extractProfileText(rawBody: string): string | null {
	const cleaned = rawBody.replace(/[\x00-\x1F\x7F]/g, " ");
	try {
		const parsed = JSON.parse(cleaned);
		if (typeof parsed?.profileText === "string") {
			return parsed.profileText;
		}
	} catch (e) {
		console.log("❌ JSON.parse failed after strip: " + e);
	}

	const match = rawBody.match(/"profileText"\s*:\s*"([\s\S]*?)"\s*[,}]/);
	if (match) {
		return match[1]
			.replace(/\\n/g, "\n")
			.replace(/\\r/g, "")
			.replace(/\\t/g, " ")
			.replace(/\\"/g, '"');
	}

	return null;
}

// 🔥 Use a regular string (not template literal) to avoid backtick conflicts
const SYSTEM_PROMPT =
	"You are a strict JSON extractor.\n\n" +
	"CRITICAL RULES:\n" +
	"- Output ONLY valid JSON\n" +
	"- No markdown, no backticks\n" +
	"- No explanation\n" +
	"- No line breaks inside string values\n" +
	"- If a field is unknown, return empty string or empty array\n\n" +
	'Return EXACTLY this schema, nothing else:\n' +
	'{"name":"","email":"","headline":"","recent_company":"","recent_role":"","experience_years":"","skills":[]}';

export default {
	async fetch(request: Request, env: any): Promise<Response> {

		// ✅ OPTIONS preflight — must return 200 with CORS headers
		if (request.method === "OPTIONS") {
			return new Response("", {
				status: 200,
				headers: corsHeaders(),
			});
		}

		if (request.method !== "POST") {
			return new Response("Method not allowed", {
				status: 405,
				headers: corsHeaders(),
			});
		}

		try {
			const rawBody = await request.text();
			console.log("📨 RAW BODY LENGTH: " + rawBody.length);

			let profileText = extractProfileText(rawBody);

			if (!profileText) {
				console.log("❌ Could not extract profileText");
				return new Response(
					JSON.stringify({ error: "profileText is required" }),
					{
						status: 400,
						headers: {
							"Content-Type": "application/json",
							...corsHeaders(),
						},
					}
				);
			}

			console.log("✅ profileText length: " + profileText.length);

			if (profileText.length > 4000) {
				profileText = profileText.substring(0, 4000);
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
						temperature: 0.1,
						max_tokens: 400,
						messages: [
							{
								role: "system",
								content: SYSTEM_PROMPT,
							},
							{
								role: "user",
								content: profileText,
							},
						],
					}),
				}
			);

			const rawText = await groqRes.text();
			console.log("🔥 GROQ RAW: " + rawText);

			let data: GroqResponse = {};
			try {
				data = JSON.parse(rawText);
			} catch (e) {
				console.log("❌ Groq response not valid JSON: " + rawText);
			}

			let content = data?.choices?.[0]?.message?.content ?? "";
			console.log("🧠 AI CONTENT: " + content);

			content = content
				.replace(/```json/g, "")
				.replace(/```/g, "")
				.replace(/[\x00-\x1F\x7F]/g, " ")
				.trim();

			let parsed: any = {};

			try {
				parsed = JSON.parse(content);
				if (typeof parsed === "string") {
					parsed = JSON.parse(parsed);
				}
			} catch (e) {
				console.log("❌ First parse failed: " + content);
				try {
					const match = content.match(/\{[\s\S]*\}/);
					if (match) {
						parsed = JSON.parse(match[0]);
					}
				} catch (e2) {
					console.log("❌ Second parse failed, returning empty profile");
					parsed = {};
				}
			}

			const finalData = normalizeProfile(parsed);
			console.log("✅ FINAL: " + JSON.stringify(finalData));

			return new Response(JSON.stringify(finalData), {
				status: 200,
				headers: {
					"Content-Type": "application/json",
					...corsHeaders(),
				},
			});

		} catch (error: any) {
			console.log("🔥 WORKER ERROR: " + (error?.message || error));

			return new Response(
				JSON.stringify({
					error: "Internal server error",
					details: error?.message || "unknown",
				}),
				{
					status: 500,
					headers: {
						"Content-Type": "application/json",
						...corsHeaders(),
					},
				}
			);
		}
	},
};