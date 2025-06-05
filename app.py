from flask import Flask, jsonify, send_from_directory
import os

app = Flask(__name__, static_folder=".", static_url_path="")

@app.route("/")
def home():
    return jsonify({
        "message": "WayMaker AI is running!",
        "status": "healthy", 
        "version": "production-v2",
        "tagline": "Your path to living God's will---step by step",
        "features": ["Biblical AI", "Age Adaptation", "Crisis Support", "Community Chat"]
    })

@app.route("/health")
def health():
    return jsonify({"status": "ok"})

@app.route("/chat")
def chat():
    try:
        return send_from_directory(".", "waymaker_enhanced_community_chat.html")
    except Exception as e:
        return jsonify({
            "error": "Chat interface not found", 
            "available_files": [f for f in os.listdir(".") if f.endswith(".html")],
            "message": "WayMaker AI chat interface will be available soon"
        })

@app.route("/apps")
def apps():
    return jsonify({
        "message": "WayMaker AI Apps Interface",
        "status": "available",
        "chat_url": "/chat",
        "features": ["Biblical Guidance", "Prayer Support", "Crisis Intervention"]
    })

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=False)
