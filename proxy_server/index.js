const express = require("express");
const cors = require("cors");
const axios = require("axios");

const app = express();
app.use(cors());
app.use(express.json());

app.post("/ask", async (req, res) => {
  const question = req.body.question;

  try {
    const groqRes = await axios.post(
      "https://api.groq.com/openai/v1/chat/completions",
      {
        model: "llama3-8b-8192",
        messages: [
          {
            role: "system",
            content: "你是一位數學師父，語氣睿智簡潔，請用繁體中文回答玩家的問題。",
          },
          { role: "user", content: question },
        ],
      },
      {
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${process.env.GROQ_API_KEY}`,
        },
      }
    );

    res.json({ reply: groqRes.data.choices[0].message.content });
  } catch (e) {
    res.status(500).json({ error: "Groq Error", message: e.message });
  }
});

app.listen(3000, () => console.log("🚀 Proxy server running on port 3000"));
