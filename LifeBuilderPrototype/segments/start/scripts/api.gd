extends Node

signal next_response(message, npc_id)
signal main_topic_set()

var api_key : String
var url : String
var header = ["Content-Type: application/json"]
var request : HTTPRequest

var last_npc = "" # Possible NPCs: "Blacksmith" | "Phantom" | "Richard"

# memory
var main_topic = ""
var last_request_message = ""

func _ready():
	set_api_key()
	connect("next_response", _api_response)

func send_api_request(message):
	last_request_message = message
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
	if !response.candidates[0].content:
		send_api_request(last_request_message)
		return
	var message = response.candidates[0].content.parts[0].text
	next_response.emit(message, last_npc)

func next_promt(text, npc):
	last_npc = npc
	if npc == "Richard-Yellow":
		send_api_request("Reflect on the following topic: " + str(main_topic) + " Try to reflect on it by responding with facts about the topic.\n\nExamples:\nI wrote 200 lines of code and spend 2 hours studying Godot.\nI wrote 2 pages using 5000 characters.\nI spend 15 hours over the last 3 days and wrote down one page in my essay.\n\nRespond in less than 20 words!")
	elif npc == "Richard-Red":
		send_api_request("Reflect on the following topic: " + str(main_topic) + " Try to reflect on it by responding with emotions about the topic.\n\nExamples:\nWhenever i make progress, i feel excited. However, sometimes it's depressing to make no progress.\nI love writing!\nI feel very negative about it. It makes me sad and depressed.\n\nRespond in less than 20 words!")
	elif npc == "Richard-Green":
		send_api_request("Reflect on the following topic: " + str(main_topic) + " Try to reflect on it by responding with optimism about the topic.\n\nExamples:\nI am growing my skills. Soon i will build way bigger projects.\nOne day i will sell a book for good money!\nTomorrow i will do better!\n\nRespond in less than 20 words!")
	elif npc == "Richard-Blue":
		send_api_request("Reflect on the following topic: " + str(main_topic) + " Try to reflect on it by responding with creative ideas regarding the topic.\n\nExamples:\nI could rebuild the UI design from other games.\nI could ask a friend for ideas to include in my writing.\nI could try working in a different place which might help my productivity.\n\nRespond in less than 20 words!")
	else: # not richard
		send_api_request("Say something clever as a response to this in less than 20 words: " + str(text))

func set_api_key():
	var env_file = FileAccess.open("res://key.env", FileAccess.READ)
	api_key = env_file.get_line().split("= ")[1]
	url = "https://generativelanguage.googleapis.com/v1/models/gemini-pro:generateContent?key=%s"%api_key
	env_file.close()

func start_richard_game():
	last_npc = "Start"
	send_api_request("Name a topic from your daily life that you could reflect upon.\n\nExamples:\nToday i learned how to develop UI elements in Godot, it went well.\nThis week i made good progress in my writing skills.\nRecently my productivity was lacking.\n\nRespond in less than 20 words!")

func _api_response(message, npc):
	if npc == "Start":
		main_topic = message
		main_topic_set.emit()
