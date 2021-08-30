tool
extends EditorPlugin

const DiagramInspector = preload("res://addons/ai_diagram/editor/ai_diagram_editor.tscn")
var editor = DiagramInspector.instance()

var focused_object setget set_focused_object
var editor_selection

var undo_redo = get_undo_redo()

func _enter_tree():
	editor_selection = get_editor_interface().get_selection()
	editor_selection.connect("selection_changed", self, "_on_EditorSelection_selection_changed")
	add_custom_type("AI_Diagram", "Node", preload("ai_diagram.gd"), preload("circle2.png"))
	editor.connect("start_diagram", self, "start_diagram")
	editor.connect("update_resource_data", self, "update_resource_data")
	editor.set_plugin_node(self)
	editor.undo_redo = undo_redo

func _exit_tree():
	remove_custom_type("AI_Diagram")
	editor.queue_free()
	pass

func show_editor():
	if focused_object and editor:
		if not editor.is_inside_tree():
			add_control_to_bottom_panel(editor, "AI Diagram")
			if focused_object.datares == null:
				editor.show_start()
			else:
				editor.hide_start()
				
		make_bottom_panel_item_visible(editor)
		
func hide_editor():
	if editor.is_inside_tree():
		remove_control_from_bottom_panel(editor)
		pass
		
func set_focused_object(obj):
	if focused_object != obj:
		focused_object = obj
		_on_focused_object_changed(obj)
		update_editor_view()
		
		
func _on_focused_object_changed(new_obj):
	if new_obj:
		show_editor()
		if focused_object and editor:
			focused_object.data_get()
	else:
		hide_editor()

func _on_EditorSelection_selection_changed():
	var selected_nodes = editor_selection.get_selected_nodes()
	if selected_nodes.size() == 1:
		var selected_node = selected_nodes[0]
		if selected_node is AI_DIAGRAM:
			set_focused_object(selected_node)
			return
		else:
			if editor:
				editor.graphnode_updated()
	set_focused_object(null)

func start_diagram():
	if focused_object:
		focused_object.create_resource()

func update_resource_data(graph):
	if focused_object and editor:
		focused_object.data_save(graph)

func update_editor_view():
	if focused_object and editor:
		if focused_object.datares != null:
			editor.rebuild_view(focused_object.datares)
