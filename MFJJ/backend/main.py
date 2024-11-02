from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/', methods=['POST'])
def locate():
    if request.method == "POST":
        if request.is_json:
            data = request.get_json()

            # send to backend

    else:
        return jsonify('{Error}')


    return jsonify(data)

if __name__ == "__main__":
    app.run(debug=True, host="10.239.101.11")