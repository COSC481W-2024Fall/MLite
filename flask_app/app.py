from flask import Flask, request, jsonify

app = Flask(__name__)

@app.route('/inference', methods=['GET'])
def inference():
    # Get `model_input` parameter from the URL query string
    model_input = request.args.get('model_input')

    # Ensure that `model_input` exists and parse it
    if model_input:
        # Expecting `model_input` to be a string that looks like "[0.1, 44, 0.1]"
        try:
            # Convert string to a list (assuming it's comma-separated)
            inputs = eval(model_input)
            # Ensure inputs are in list form
            if not isinstance(inputs, list):
                return jsonify({"error": "model_input must be a list"}), 400

            # Generate dummy response based on input
            result = ", ".join(map(str, inputs))
            return jsonify({"result": result})

        except (SyntaxError, NameError):
            return jsonify({"error": "Invalid format for model_input"}), 400
    else:
        return jsonify({"error": "model_input parameter is required"}), 400

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000)
