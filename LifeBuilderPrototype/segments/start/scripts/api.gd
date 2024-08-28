extends Node

signal next_response(message, npc_id)

var api_key : String
var url : String
var header = ["Content-Type: application/json"]
var request : HTTPRequest

var last_npc # Possible NPCs: "Blacksmith" | "Phantom" | "Richard"

func _ready():
	set_api_key()

func send_api_request(message):
	request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", _on_request_completed)
	dialogue_request(message)

func dialogue_request(player_dialogue):
	var contents_value = []
	contents_value.append({
			"role":"user",
			"parts":[{"text":player_dialogue}]
		})
	var body = JSON.stringify({
		"contents":contents_value
	})
	var send_request = request.request(url, header, HTTPClient.METHOD_POST, body)
	if send_request != OK:
		print("There was an error!")

func _on_request_completed(_result, _response_code, _headers, body):
	var json = JSON.new()
	json.parse(body.get_string_from_utf8())
	var response = json.get_data()
	var message = response.candidates[0].content.parts[0].text
	next_response.emit(message, last_npc)

func next_promt(text, npc):
	send_api_request("You are trying to help the user reflect and understand their own approach and behaviour in various topics. You are metaphorically an old adventurer that has seen many things. Now you are trying to help them with your knowledge and your perspective. Try reflecting yourself in your responses. Respond very shortly in less than 20 words, and in text only. The following is the message of the user: " + str(text))
	last_npc = npc

func set_api_key():
	var env_file = FileAccess.open("res://API_KEY.env", FileAccess.READ)
	api_key = env_file.get_line().split("= ")[1]
	url = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=%s"%api_key
	env_file.close()
