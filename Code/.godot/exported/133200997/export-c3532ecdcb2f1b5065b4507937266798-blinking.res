RSRC                    VisualShader            ��������                                            /      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    linked_parent_graph_frame    input_name    script 	   operator 	   constant 	   function    code    graph_offset    mode    modes/blend    flags/skip_vertex_transform    flags/unshaded    flags/light_only    flags/world_vertex_coords    nodes/vertex/0/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/6/node    nodes/fragment/6/position    nodes/fragment/7/node    nodes/fragment/7/position    nodes/fragment/8/node    nodes/fragment/8/position    nodes/fragment/9/node    nodes/fragment/9/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections        $   local://VisualShaderNodeInput_6u2qn       &   local://VisualShaderNodeFloatOp_s1ucc O      ,   local://VisualShaderNodeFloatConstant_yrj7y �      (   local://VisualShaderNodeFloatFunc_3mhpk �      &   res://ressources/shader/blinking.tres �         VisualShaderNodeInput             time          VisualShaderNodeFloatOp                      VisualShaderNodeFloatConstant    	        �@         VisualShaderNodeFloatFunc              
                  VisualShader          *  shader_type canvas_item;
render_mode blend_add;




void fragment() {
// Input:6
	float n_out6p0 = TIME;


// FloatConstant:8
	float n_out8p0 = 6.000000;


// FloatOp:7
	float n_out7p0 = n_out6p0 * n_out8p0;


// FloatFunc:9
	float n_out9p0 = cos(n_out7p0);


// Output:0
	COLOR.a = n_out9p0;


}
                                
     �C  4�                
     ��  4�               
     ��  4�               
     ��  ��               
     \C   �                              	                     	                    RSRC