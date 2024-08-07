`include "params.vh"

module game_logic(
	input [INPUT_DEPTH-1:0] p1_inputs,
	input [INPUT_DEPTH-1:0] p2_inputs,
	input frame_clk,
	input sys_clk,
	input rst,
	output [STATE_DEPTH-1:0] p1_state,
	output [STATE_DEPTH-1:0] p2_state,
	output [POSITION_DEPTH-1:0] p1_position,
	output [POSITION_DEPTH-1:0] p2_position,
	output [SPRITE_INDEX_DEPTH-1:0] p1_sprite,
	output [SPRITE_INDEX_DEPTH-1:0] p2_sprite,
	output done_gen
);
	// Player registers:
	// State, position, activeframe
	reg [STATE_DEPTH-1:0] reg_p1_state;
	reg [STATE_DEPTH-1:0] reg_p2_state;
	reg [POSITION_DEPTH-1:0] reg_p1_position;
	reg [POSITION_DEPTH-1:0] reg_p2_position;
	reg [SPRITE_INDEX_DEPTH-1:0] reg_p1_sprite;
	reg [SPRITE_INDEX_DEPTH-1:0] reg_p2_sprite;
	
	wire [STATE_DEPTH-1:0] wire_p1_state;
	wire [STATE_DEPTH-1:0] wire_p2_state;
	wire [POSITION_DEPTH-1:0] wire_p1_position;
	wire [POSITION_DEPTH-1:0] wire_p2_position;
	wire [SPRITE_INDEX_DEPTH-1:0] wire_p1_sprite;
	wire [SPRITE_INDEX_DEPTH-1:0] wire_p2_sprite;
	wire p1_done;
	wire p2_done;
	wire p1_attack_connected;
	wire p2_attack_connected;
	
	game_logic p1(
		.sys_clk(sys_clk),
		.frame_clk(frame_clk),
		.reset(rst),
		.player_buttons(p1_inputs),
		.player_state(reg_p1_state),
		.player_sprite(reg_p1_sprite),
		.player_position(reg_p1_position),
		.other_player_position(reg_p2_position),
		.player_num(1'b0),
		.opponent_attack_connected(p2_attack_connected),
		.player_attack_connected(p1_attack_connected),
		.next_state(wire_p1_state),
		.sprite_index(wire_p1_sprite),
		.next_position(wire_p1_position),
		.done_gen(p1_done)
	);
	
	game_logic p2(
		.sys_clk(sys_clk),
		.frame_clk(frame_clk),
		.reset(rst),
		.player_buttons(p2_inputs),
		.player_state(reg_p2_state),
		.player_sprite(reg_p2_sprite),
		.player_position(reg_p2_position),
		.other_player_position(reg_p1_position),
		.player_num(1'b0),
		.opponent_attack_connected(p1_attack_connected),
		.player_attack_connected(p2_attack_connected),
		.next_state(wire_p2_state),
		.sprite_index(wire_p2_sprite),
		.next_position(wire_p2_position),
		.done_gen(p2_done)
	);
	
	hit_calculator h(
		.p1_state(reg_p1_state),
		.p2_state(reg_p2_state),
		.p1_position(reg_p1_position),
		.p2_position(reg_p2_position),
		.p1_frame(reg_p1_sprite),
		.p2_frame(reg_p2_frame),
		.clk(sys_clk),
		.p1_connects(p1_attack_connected),
		.p1_hit(p1_got_hit),
		.p2_connects(p2_attack_connected),
		.p2_hit(p2_got_hit)
	)
	
	always@(posedge frame_clk, negedge rst) begin
		if(rst == 1'b0) begin
			reg_p1_state <= NOTHING;
			reg_p2_state <= NOTHING;
			reg_p1_position <= P1_START;
			reg_p2_position <= P2_START;
			reg_p1_sprite <= 0;
			reg_p2_sprite <= 0;
		end else begin
			reg_p1_state <= wire_p1_state;
			reg_p2_state <= wire_p2_state;
			reg_p1_sprite <= wire_p1_sprite;
			reg_p2_sprite <= wire_p2_sprite;
			reg_p1_position <= wire_p1_position;
			reg_p2_position <= wire_p2_position;
		end
	end
	
	assign p1_state = reg_p1_state;
	assign p2_state = reg_p2_state;
	assign p1_position = reg_p1_position;
	assign p2_position = reg_p2_position;
	assign p1_sprite = reg_p1_sprite;
	assign p2_sprite = reg_p2_sprite;
	assign done_gen = p1_done & p2_done;

endmodule