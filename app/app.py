from flask import Flask

app = Flask(__name__)

@app.get("/")
def hello():
    return "Hello World!", 200

if __name__ == "__main__":
    # Приложение слушает на 0.0.0.0 и порту из переменной окружения
    import os
    port = int(os.getenv("APP_PORT", 5000))
    app.run(host="0.0.0.0", port=port)