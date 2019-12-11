Import mojo
Import brl
Global Prototype:DungeonGen

Function Main()
	Prototype = New DungeonGen	
End



Class DungeonGen Extends App
	Field Room1:RoomMap
	Field GameState:String = "START"
	
	Method OnCreate()
		Room1 = New RoomMap
		
	End
	
	Method OnUpdate()
		Select GameState
			Case "START"
				If KeyHit(KEY_SPACE) Then
					Seed = Millisecs()
					Room1.Build()
					GameState = "PLAYING"
				End
			Case "PLAYING"
				If KeyHit(KEY_ESCAPE) Then
					Room1.Reset()
					GameState = "START"
				End
		End
	End
	
	Method OnRender()
		Select GameState
			Case "START"
				Cls(0,0,0)
				SetColor(255,255,255)
				DrawText("Press Space to Start", 255, 255)
			Case "PLAYING"
				Cls(0,0,0)
				Room1.Draw()
				SetColor(255,255,255)
				DrawText("Press ESC to reset", 255, 255)
				DrawText("Seed:", 255, 300)
				DrawText(Seed, 300, 300)
		End
	End

End

Class Room
	Field Type:Int
	Field Neighbours:Int
	Field x:Int
	Field y:Int
	Field nDoor:String = "0"
	Field eDoor:String = "0"
	Field wDoor:String = "0"
	Field sDoor:String = "0"
	Field DoorArray:String[]
	
	Method New(Type:Int, X:Int, Y:Int)
		Self.x = X
		Self.y = Y
		Self.Type = Type
	End
	
	Method GetDoors:String()
		DoorArray =[nDoor, eDoor, sDoor, wDoor]
		Return ("".Join(DoorArray))
	End
	
	Method SetnDoor(_nDoor:String)
		Self.nDoor = _nDoor
	End
	
	Method SetsDoor(_sDoor:String)
		Self.sDoor = _sDoor
	End
	
	Method SeteDoor(_eDoor:String)
		Self.eDoor = _eDoor
	End
	
	Method SetwDoor(_wDoor:String)
		Self.wDoor = _wDoor
	End
	

	Method UpdateNeighbours(Amount:Int)
		Self.Neighbours += Amount
	End
	
	Method UpdateType(Type:Int)
		Self.Type = Type
	End
	
	Method GetNeighbours()
		Return Neighbours
	End
	
	Method GetType()
		Return Type
	End
	
	Method GetX()
		Return Self.x
	End
	
	Method GetY()
		Return Self.y
	End
	Method Reset()
		Self.Type = 0
		Self.Neighbours = 0
		Self.nDoor = "0"
		Self.eDoor = "0"
		Self.sDoor = "0"
		Self.wDoor = "0"
	End
End



Class RoomMap
	Field Map:Room[6][]
	Field MapHeight = 6
	Field MapWidth = 6
	Field MapPSize = 32
	Field MapXOffset:Int = 0
	Field roomNum:Int = 15
	
	Method Build()
		Local RoomCount:Int = 0
		'Setting up room array
		For Local i = 0 To MapWidth - 1
			Map[i] = New Room[MapHeight]
		Next
		
		'Creating room objects
		For Local i = 0 To MapWidth - 1
			For Local j = 0 To MapHeight - 1
				Map[i][j] = New Room(0,i,j)
			Next
		Next
		
		
		'Finding the starting room
		Local xr:Int = (Rnd() * MapWidth)
		Local yr:Int = (Rnd() * MapHeight)
		Map[xr][yr].UpdateType(1)
		RoomCount += 1
		'Updating Neighbour Count for surrounding rooms
		If xr > 0 And xr < MapWidth - 1
			Map[xr+1][yr].UpdateNeighbours(1)
			Map[xr-1][yr].UpdateNeighbours(1)
		Elseif xr = 0
			Map[xr+1][yr].UpdateNeighbours(1)
		Elseif xr = MapWidth - 1
			Map[xr-1][yr].UpdateNeighbours(1)
		End
		
		If yr > 0 And yr < MapHeight - 1
			Map[xr][yr+1].UpdateNeighbours(1)
			Map[xr][yr-1].UpdateNeighbours(1)
		Elseif yr = 0
			Map[xr][yr+1].UpdateNeighbours(1)
		Elseif yr = MapHeight - 1
			Map[xr][yr-1].UpdateNeighbours(1)
		End
		
	'Filling out rest of rooms	
	While RoomCount < roomNum
		Local Valid:List<Room> = New List<Room>
		'Checks for Valid Next Rooms
		For Local i = 0 To MapWidth - 1
			For Local j = 0 To MapHeight - 1
				If Map[i][j].GetNeighbours = 1 And Map[i][j].GetType = 0
					Valid.AddLast Map[i][j]
				End
			Next
		Next
		
		'Converts list to array
		Local validRoomArray:Room[] = Valid.ToArray
		
		'Choose random room from list, update its type and increase room count
		Local ir:Int = (Rnd() * validRoomArray.Length - 1)
		validRoomArray[ir].UpdateType(2)
		RoomCount += 1
		
		'Find the x and y values of the chosen room
		Local x:Int = validRoomArray[ir].GetX()
		Local y:Int = validRoomArray[ir].GetY()
		
			'Update surrounding rooms neighbour value
			If x > 0 And x < MapWidth - 1
				Map[x + 1][y].UpdateNeighbours(1)
				Map[x - 1][y].UpdateNeighbours(1)
			ElseIf x = 0
				Map[x + 1][y].UpdateNeighbours(1)
			Elseif x = MapWidth - 1
				Map[x - 1][y].UpdateNeighbours(1)
			End
		
			If y > 0 And y < MapHeight - 1
				Map[x][y + 1].UpdateNeighbours(1)
				Map[x][y - 1].UpdateNeighbours(1)
			ElseIf y = 0
				Map[x][y + 1].UpdateNeighbours(1)
			Elseif y = MapHeight - 1
				Map[x][y - 1].UpdateNeighbours(1)
			End
	
	End While
	
	'Find where doors need to be placed in each room
	For Local x:Int = 0 To MapWidth - 1
		For Local y:Int = 0 To MapHeight - 1
			If Map[x][y].GetType <> 0
				If y > 0 Then
					If Map[x][y - 1].GetType <> 0 and y > 0 Then
						Map[x][y].SetnDoor("1")
					EndIf
				EndIf
				If y < MapHeight - 1 Then
					If Map[x][y + 1].GetType <> 0 And y < MapHeight - 1 Then
						Map[x][y].SetsDoor("1")
					EndIf
				EndIf
				If x > 0 Then
					If Map[x - 1][y].GetType <> 0 and x > 0 Then
						Map[x][y].SetwDoor("1")
					EndIf
				EndIf
				If x < MapWidth - 1
					If Map[x + 1][y].GetType <> 0 And x < MapWidth - 1 Then
						Map[x][y].SeteDoor("1")
					EndIf
				EndIf
			EndIf
		Next
	Next
	
	End
	
	Method Draw()
		'Draws current map to the screen
		Cls(0,0,0)
		'SetColor(255,0,0)
		'DrawRect(MapXOffset - 10, 0,(MapWidth*32)+20,(MapHeight*32)+10)
		For Local x = 0 To MapWidth - 1
			For Local y = 0 To MapHeight - 1
				Select Map[x][y].GetType
					Case 0 'blank room
						SetColor(0, 0, 0)
						DrawRect((x * MapPSize) + MapXOffset, y * MapPSize, MapPSize, MapPSize)
					Case 1 'starting room
						SetColor(255, 255, 255)
						DrawRect((x * MapPSize) + MapXOffset, y * MapPSize, MapPSize, MapPSize)
						Select Map[x][y].GetDoors 'Position NESW
							Case "1000"
								DrawRoom("StartRoom/N.png", x, y, MapPSize)
							Case "0100"
								DrawRoom("StartRoom/E.png", x, y, MapPSize)
							Case "0010"
								DrawRoom("StartRoom/S.png", x, y, MapPSize)
							Case "0001"
								DrawRoom("StartRoom/W.png", x, y, MapPSize)
							Case "1100"
								DrawRoom("StartRoom/NE.png", x, y, MapPSize)
							Case "1010"
								DrawRoom("StartRoom/NS.png", x, y, MapPSize)
							Case "1001"
								DrawRoom("StartRoom/NW.png", x, y, MapPSize)
							Case "1110"
								DrawRoom("StartRoom/NES.png", x, y, MapPSize)
							Case "1101"
								DrawRoom("StartRoom/NEW.png", x, y, MapPSize)
							Case "0110"
								DrawRoom("StartRoom/ES.png",x, y, MapPSize)
							Case "0011"
								DrawRoom("StartRoom/SW.png", x, y, MapPSize)
							Case "0111"
								DrawRoom("StartRoom/ESW.png", x, y, MapPSize)
							Case "1011"
								DrawRoom("StartRoom/NSW.png",x, y, MapPSize)
							Case "0101"
								DrawRoom("StartRoom/EW.png", x, y, MapPSize)
							Case "1111"
								DrawRoom("StartRoom/NESW.png", x, y, MapPSize)
						End
					Case 2 'filled room
						SetColor(255, 255, 255)
						DrawRect((x * MapPSize)+ MapXOffset, y * MapPSize, MapPSize, MapPSize)
						Select Map[x][y].GetDoors 'Position NESW
							Case "1000"
								DrawRoom("Room/N.png", x, y, MapPSize)
							Case "0100"
								DrawRoom("Room/E.png", x, y, MapPSize)
							Case "0010"
								DrawRoom("Room/S.png", x, y, MapPSize)
							Case "0001"
								DrawRoom("Room/W.png", x, y, MapPSize)
							Case "1100"
								DrawRoom("Room/NE.png", x, y, MapPSize)
							Case "1010"
								DrawRoom("Room/NS.png", x, y, MapPSize)
							Case "1001"
								DrawRoom("Room/NW.png", x, y, MapPSize)
							Case "1110"
								DrawRoom("Room/NES.png", x, y, MapPSize)
							Case "1101"
								DrawRoom("Room/NEW.png", x, y, MapPSize)
							Case "0110"
								DrawRoom("Room/ES.png", x, y, MapPSize)
							Case "0011"
								DrawRoom("Room/SW.png", x, y, MapPSize)
							Case "0111"
								DrawRoom("Room/ESW.png", x, y, MapPSize)
							Case "1011"
								DrawRoom("Room/NSW.png", x, y, MapPSize)
							Case "0101"
								DrawRoom("Room/EW.png", x, y, MapPSize)
							Case "1111"
								DrawRoom("Room/NESW.png", x, y, MapPSize)
						End
				End
			Next
		Next
		
	End
	
	Method Reset()
	'used to reset map array to create new map
		For Local x = 0 To MapWidth - 1
			For Local y = 0 To MapHeight - 1
				Map[x][y].Reset()
			Next
		Next
	End
End

Function DrawRoom(path:String, x:Int, y:Int, mapPSize:Int)
	Local Room:Image
	Local ImageSize:Int = 32
	Room = LoadImage(path, ImageSize, ImageSize, 1)
	DrawImage(Room, (x*mapPSize) + 0, y*mapPSize)
End




