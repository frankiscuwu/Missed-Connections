from flask import Flask, jsonify, request

app = Flask(__name__)

@app.route('/locate', methods=['GET', 'POST'])
def locate():
    if request.method == "POST":
        if request.is_json:
            data = request.get_json()

            # debug
            print(data)

            # send to backend

            return jsonify(data)

    elif request.method == "GET":
        return 'Hi frank'
    else:
        return jsonify('{Error}')


if __name__ == "__main__":
    app.run(debug=True, host="10.239.101.11")