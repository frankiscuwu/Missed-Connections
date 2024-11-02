from flask import Flask, jsonify

app = Flask(__name__)

@app.route("/locate")
def locate():
    data = {
        "lat": "-42",
        "long": "42",
        "name": "joe"
    }
    return jsonify(data)

if __name__ == "__main__":
    app.run(debug=True)