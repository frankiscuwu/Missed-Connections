from flask import Flask, jsonify, request, abort
from db_services import add_location_item, init_db, get_proximate_users

init_db()

app = Flask(__name__)

@app.route('/locate', methods=['GET', 'POST'])
def locate():
    if request.method == "POST":
        if request.is_json:
            data = request.get_json()

            # debug
            print(data)
            print(type(data))

            # send to backend
            add_location_item(data)
            return jsonify({'users': get_proximate_users(data)})

    elif request.method == "GET":
        return 'Hi frank'
    else:
        return abort(404)


if __name__ == "__main__":
    app.run(debug=True, host="10.239.101.11")