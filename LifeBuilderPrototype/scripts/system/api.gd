extends Node

signal next_response(message, npc_id)

var api_key : String = "AIzaSyDlFWpV7DbOWOlbeFmEtVF_gNWESO0WCio" # << insert api key here
var url : String = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=%s"%api_key
var header = ["Content-Type: application/json"]
var request : HTTPRequest

var npc_id = -1
var npc = "NO_NPC"
var contents_value

var last_chat_file
var first_msg
var dialogue_active
var initial_string = "I want to reflect on my learning progress. Can you help me by playing my coach and ask me one question at a time. Wait for my response. Always respond in less than 50 words. The following describes what i want to reflect on: " # Additionally talk like a blacksmith.
var blacksmith_string = ". Add add a blacksmith themed sentence at the end of your response."
var phantom_string = ". Add add a phantom themed sentence at the end of your response."

func _ready():
	contents_value = []
	last_chat_file = FileAccess.open("res://dialogue/last_chat.txt", FileAccess.WRITE)
	first_msg = true
	dialogue_active = false

func send_api_request(message):
	request = HTTPRequest.new()
	add_child(request)
	request.connect("request_completed", _on_request_completed)
	dialogue_request(message)

func dialogue_request(player_dialogue):
	contents_value.append({
			"role":"user",
			"parts":[{"text":player_dialogue}]
		})
	last_chat_file.store_string("Player: " + player_dialogue + "\n")
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
	if response.candidates[0].has("content"):
		var message = response.candidates[0].content.parts[0].text
		next_response.emit(message, npc_id)
		contents_value.append({
				"role":"model",
				"parts":[{"text":message}]
			})
		if npc_id == 0:
			npc = "Blacksmith: "
		if npc_id == 1:
			npc = "Phantom: "
		last_chat_file.store_string(npc + message + "\n")
	else:
		print(response.candidates[0])

func _on_blacksmith_next_prompt(input):
	npc_id = 0
	
	if first_msg == true:
		input = initial_string + input
		first_msg = false
	
	if !dialogue_active:
		last_chat_file.store_string("\n-------- NEW CHAT --------\nBlacksmith: Hi! My name is Borkir. What do you want to reflect on?\n")
		input = input# + blacksmith_string
		dialogue_active = true
		
	send_api_request(input)

func _on_phantom_next_prompt(input):
	npc_id = 1
	
	if first_msg == true:
		input = initial_string + input
		first_msg = false
	
	if !dialogue_active:
		last_chat_file.store_string("\n-------- NEW CHAT --------\nPhantom: Sha-Aksh!\n")
		input = input# + phantom_string
		dialogue_active = true
	
	send_api_request(input)

func _on_blacksmith_dialogue_finished():
	dialogue_active = false

func _on_phantom_dialogue_finished():
	dialogue_active = false
