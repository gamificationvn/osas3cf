/**
 * The MIT License
 * Copyright (c) 2010 Craig Simpson
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 **/
package org.osas3cf.validation.rules.chess
{
	import flash.geom.Point;
	
	import org.osas3cf.board.ChessPieces;
	import org.osas3cf.data.BitBoard;
	import org.osas3cf.data.ChessBitBoards;
	import org.osas3cf.utility.BitOper;
	import org.osas3cf.utility.BoardUtil;
	import org.osas3cf.validation.rules.IPieceRule;
	
	public class Diagonals implements IPieceRule
	{
		private var _name:String;
		
		public function Diagonals(pieceName:String = "Bishop")
		{
			_name = pieceName;
		}
		
		public function execute(bitBoards:Array):void
		{
			var squares:Array = BoardUtil.getTrueSquares(bitBoards[_name + ChessBitBoards.S]);
			var color:String;
			var attacks:Object;
			var move:Array;

			for each(var square:String in squares)
			{
				color = (BoardUtil.isTrue(square, bitBoards[ChessPieces.WHITE + ChessBitBoards.S])) ? ChessPieces.WHITE : ChessPieces.BLACK;
				attacks = findAttacks(square, color, bitBoards);
				move = BitOper.and(attacks.piece, BitOper.not(BitOper.and(attacks.piece, bitBoards[color + ChessBitBoards.S])));
				bitBoards[color  + ChessBitBoards.ATTACK] = bitBoards[color  + ChessBitBoards.ATTACK] ? BitOper.or(bitBoards[color + ChessBitBoards.ATTACK], attacks.piece) : attacks.piece;
				bitBoards[square + ChessBitBoards.ATTACK] = bitBoards[square + ChessBitBoards.ATTACK] ? BitOper.or(bitBoards[square + ChessBitBoards.ATTACK], attacks.piece) : attacks.piece;
				bitBoards[color  + ChessBitBoards.XRAY] = bitBoards[color  + ChessBitBoards.ATTACK] ? BitOper.or(bitBoards[color + ChessBitBoards.ATTACK], attacks.xray) : attacks.xray;
				bitBoards[square + ChessBitBoards.XRAY] = bitBoards[square + ChessBitBoards.ATTACK] ? BitOper.or(bitBoards[square + ChessBitBoards.ATTACK], attacks.xray) : attacks.xray;
				bitBoards[square + ChessBitBoards.MOVE] = bitBoards[square + ChessBitBoards.MOVE] ? BitOper.or(bitBoards[square + ChessBitBoards.MOVE], move) : move;
				bitBoards[color + ChessBitBoards.MOVE] = bitBoards[color + ChessBitBoards.MOVE] ? BitOper.or(bitBoards[color + ChessBitBoards.MOVE], move) : move;
			}
		}
		
		private function findAttacks(square:String, color:String, bitBoards:Array):Object
		{
			var attack:BitBoard = new BitBoard();
			var xray:BitBoard = new BitBoard();
			var oppositeColor:String = (color == ChessPieces.WHITE) ? ChessPieces.BLACK : ChessPieces.WHITE;
			var start:Point = BoardUtil.squareToArrayNote(square);
			//Go left and up
			var i:int = 0;
			var j:int = start.x + 1;
			var stop:Boolean;
			for(i = start.y - 1; i >= 0; i--)
			{			
				if(j > 7)break;
				if(!stop){
					attack[j][i] = 1;
					if(bitBoards[ChessBitBoards.ALL_PIECES][j][i])
						stop = true;	
				}
				xray[j][i] = 1;
				j++;
			}
			//Go right and up
			j = start.x + 1;
			stop = false;
			for(i = start.y + 1; i < 8; i++)
			{
				if(j > 7)break;
				if(!stop){
					attack[j][i] = 1;
					if(bitBoards[ChessBitBoards.ALL_PIECES][j][i]) 
						stop = true;
				}
				xray[j][i] = 1;
				j++;
			}
			//Go left and down
			j = start.x - 1;
			stop = false;
			for(i = start.y - 1; i >= 0; i--)
			{			
				if(j < 0)break;
				if(!stop){
					attack[j][i] = 1;
					if(bitBoards[ChessBitBoards.ALL_PIECES][j][i]) 
						stop = true;
				}
				xray[j][i] = 1;
				j--;
			}
			//Go right and down
			j = start.x - 1;
			stop = false;
			for(i = start.y + 1; i < 8; i++)
			{				
				if(j < 0)break;
				if(!stop){
					attack[j][i] = 1;
					if(bitBoards[ChessBitBoards.ALL_PIECES][j][i])
						stop = true;
				}
				xray[j][i] = 1;
				j--;
			}
			return {piece:attack, xray:xray};
		}
		
		public function get name():String
		{
			return _name;
		}
	}
}