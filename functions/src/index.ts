import * as functions from "firebase-functions";
import axios from "axios";

export const extractProfile = functions.https.onRequest(async (req, res) => {
  try {
    const profileText = req.body.profileText;

    if (!profileText) {
      res.status(400).json({ error: "profileText is required" });
      return;
    }

    const response = await axios.post(
      "https://api.groq.com/openai/v1/chat/completions",
      {
        model: "llama-3.3-70b-versatile",
        temperature: 0.2,
        messages: [
          {
            role: "system",
            content: ` You are a strict data extraction engine.

                TASK:
                Extract structured information from a user profile.

                RULES:
                - Output ONLY valid JSON
                - No explanation, no markdown
                - If missing → return empty string or []
                - Do NOT hallucinate

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
            content: profileText
          }
        ]
      },
      {
        headers: {
          Authorization: `Bearer ${process.env.GROQ_API_KEY}`,
          "Content-Type": "application/json"
        }
      }
    );

    let content = response.data.choices[0].message.content;

    content = content.replace(/```json/g, "").replace(/```/g, "").trim();

    try {
      const parsed = JSON.parse(content);
      res.status(200).json(parsed); // ✅ no return
    } catch (e) {
      res.status(200).json({
        error: "Invalid JSON from AI",
        raw: content
      }); // ✅ no return
    }

  } catch (error: any) {
    console.error(error);
    res.status(500).json({ error: "Internal server error" }); // ✅ no return
  }
});

// export const extractProfile = functions.https.onRequest(async (req, res) => {
//   try {
//     const profileText = req.body.profileText;

//     if (!profileText) {
//       return res.status(400).json({error: "profileText is required"});
//     }

//     const response = await axios.post(
//       "https://api.groq.com/openai/v1/chat/completions",
//       {
//         model: "llama-3.3-70b-versatile",
//         temperature: 0.2,
//         messages: [
//           {
//             role: "system",
//             content: `
// You are a strict data extraction engine.

// TASK:
// Extract structured information from a user profile.

// RULES:
// - Output ONLY valid JSON
// - No explanation, no markdown
// - If missing → return empty string or []
// - Do NOT hallucinate

// SCHEMA:
// {
//   "name": "",
//   "headline": "",
//   "recent_company": "",
//   "recent_role": "",
//   "experience_years": "",
//   "skills": []
// }
// `,
//           },
//           {
//             role: "user",
//             content: profileText,
//           },
//         ],
//       },
//       {
//         headers: {
//           "Authorization": `Bearer ${process.env.GROQ_API_KEY}`,
//           "Content-Type": "application/json",
//         },
//       }
//     );

//     let content = response.data.choices[0].message.content;

//     // 🔥 Clean possible markdown wrapping
//     content = content.replace(/```json/g, "").replace(/```/g, "").trim();

//     try {
//       const parsed = JSON.parse(content);
//       return res.status(200).json(parsed);
//     } catch (e) {
//       return res.status(200).json({
//         error: "Invalid JSON from AI",
//         raw: content,
//       });
//     }
//   } catch (error: any) {
//     console.error(error.response?.data || error.message);
//     return res.status(500).json({error: "Internal server error"});
//   }
// });
