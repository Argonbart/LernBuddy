extends Node

signal next_response(message, npc_id)

var api_key : String = "AIzaSyDlFWpV7DbOWOlbeFmEtVF_gNWESO0WCio" # << insert api key here
var url : String = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=%s"%api_key
var header = ["Content-Type: application/json"]
var request : HTTPRequest

var npc_id = -1

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
	next_response.emit(message, npc_id)

func _on_blacksmith_next_prompt(input):
	npc_id = 0
	send_api_request(input + " Respond that in less than 50 words. Additionally talk like a blacksmith.")

func _on_phantom_next_prompt(input):
	npc_id = 1
	send_api_request(input + " Respond that in less than 50 words. Additionally talk like a phantom.")
