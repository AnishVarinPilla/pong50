push = require 'push'

Class = require 'class'

require 'Paddle'

require 'Ball'

Window_Width=1280 --The window width 
Window_Height=720 --The window height

Virtual_Width=432 --creatng a virtual window width to display the Game Name 
Virtual_Height=243 -- creating a virtual window heigth

Paddle_Speed=200  --The speed of the paddle

function love.load()

    smallfont=love.graphics.newFont('font.ttf',8)

    scorefront=love.graphics.newFont('font.ttf',30)

    math.randomseed(os.time())


    push:setupScreen(Virtual_Width,Virtual_Height,Window_Width,Window_Height,{
        fullscreen =false,
        resizable = false,
        vsync = true
    })

    player1=Paddle(10,30,5,20)
    player2=Paddle(Virtual_Width-10,Virtual_Height-30,5,20 )

    ball=Ball(Virtual_Width/2-2,Virtual_Height/2-2,4,4)

    player1Score=0  --The Left Side Player Score
    player2Score=0  --The Right Side PLayer Score

    sounds = {
        ['paddle_hit'] = love.audio.newSource('sounds/paddle_hit.wav','static'),
        ['score'] = love.audio.newSource('sounds/score.wav','static'),
        ['wall_hit'] = love.audio.newSource('sounds/wall_hit.wav','static'),
        ['start'] = love.audio.newSource('sounds/start.wav','stream'),
        ['win'] = love.audio.newSource('sounds/win.wav','stream')
    }

    gameState='start'
    sounds['start']:play()
    

end

--[[That is the main fuction that we wanted to load to initialize the graphical window
for the game state.]]


function love.keypressed(key)
    if key =='escape' then
        love.event.quit()  --to close the graphic window
    elseif key=='enter' or key=='return' then
        if gameState=='start' then 
            gameState='play'  --to switch the gamemode from the start screen or mode to play mode to play the game
        else 
           gameState='start'  --this entire block of code is written when you want to restart the game in either the middle of the game or after the game is over
           player1Score=0
           player2Score=0
           ball:reset()
           sounds['start']:play()
        end
    end

    if key=='space' then
        if gameState=='serve' then
            gameState='play'
        end
   end
end



function love.draw()
    
    love.graphics.setColor(love.math.colorFromBytes(255, 255, 255)) --setting color of the objects created to dark purple by writing the decimal value

    push:apply('start')

    
    love.graphics.clear(50/255, 0, 50/255, 1) --clearing the screen with a specific color; in this case a similar color(white)
    love.graphics.setFont(smallfont)
    
    love.window.setTitle("PONG")
    
    if gameState=='start' then 
        love.graphics.printf('Hello Pong!!! Start The Game', --Text to be shown
         0, --Our x co-ordinate but since we using center align no input
         20, 
         Virtual_Width, --this is to indicate that the text should be within this pixel range
         'center')--Center alignment
    elseif gameState=='play'then 
        love.graphics.printf('Hello Pong!!! Play The Game and Win', --Text to be shown
         0, --Our x co-ordinate but since we using center align no input
         20, 
         Virtual_Width, --this is to indicate that the text should be within this pixel range
         'center')--Center alignment
        
    end
    if gameState=='serve' then
        if servingPlayer==1 then
            love.graphics.printf("Player 1 Serve Press Space",0,20,Virtual_Width,'center')
        else
            love.graphics.printf("Player 2 Serve Press Space",0,20,Virtual_Width,'center')
        end
    end


    
    love.graphics.setFont(scorefront)
    love.graphics.print(tostring(player1Score),Virtual_Width/2-50,Virtual_Height/3)
    love.graphics.print(tostring(player2Score),Virtual_Width/2+30,Virtual_Height/3)

    if gameState=='win' then
        sounds['win']:play()
        if winningplayer==1 then
            love.graphics.printf('Player 1 Wins Woohoo!!!',0,Virtual_Height/2,Virtual_Width,'center')
        else
            love.graphics.printf('Player 2 Wins Woohoo!!!',0,Virtual_Height/2,Virtual_Width,'center')
        end
    end

   
    player1:render()
    player2:render()

    ball:render()

    DisplayFPS()

    push:apply('end') 


end

function love.update(dt)

    player1:update(dt)
    player2:update(dt)

    


    if love.keyboard.isDown('w') then
        player1.dy=-Paddle_Speed
    elseif love.keyboard.isDown('s') then 
        player1.dy=Paddle_Speed
    else
        player1.dy=0
    end
    
    if love.keyboard.isDown('up') then
        player2.dy=-Paddle_Speed
    elseif love.keyboard.isDown('down') then 
        player2.dy=Paddle_Speed
    else
        player2.dy=0
    end

    if gameState=='serve' then
        ball.dy=math.random(-50,50)
        if servingPlayer==1 then
            ball.dx=math.random(120,200)
        else
            ball.dx= -math.random(120,200)
        end
    elseif  gameState =='play' then

        ball:update(dt)

        if ball:collides(player1) then
            ball.dx=-ball.dx*1.10
            ball.x=player1.x+5

            sounds['paddle_hit']:play()

            if ball.dy<0 then 
                ball.dy=-math.random(10,150)
            else 
                ball.dy=math.random(10,150)
            end
        end

        if ball:collides(player2) then
            ball.dx=-ball.dx*1.10
            ball.x=player2.x-4

            sounds['paddle_hit']:play()

            if ball.dy<0 then 
                ball.dy=-math.random(10,150)
            else 
                ball.dy=math.random(10,150)
            end
        end
        
        if ball.y<=0 then
            ball.y=0
            ball.dy=-ball.dy
            sounds['wall_hit']:play()
        end

        if ball.y>= Virtual_Height-4 then
            ball.y=Virtual_Height-4
            ball.dy=-ball.dy
            sounds['wall_hit']:play()
        end

        if ball.x<0 then 
            servingPlayer = 1
            player2Score=player2Score+1
            
            
            if player2Score==10 then
                winningplayer=2
                gameState='win'
            else
                sounds['score']:play()
                ball:reset()
                gameState='serve'
            end
            
        end

        if ball.x>Virtual_Width then 
            servingPlayer = 2
            player1Score=player1Score+1
            if player1Score==10 then
                winningplayer=1
                gameState='win'
            else
                sounds['score']:play()
                ball:reset()
                gameState='serve'
            end
        end
    end
end


function DisplayFPS()
    love.graphics.setColor(love.math.colorFromBytes(0, 100, 0))
    love.graphics.setFont(smallfont)
    love.graphics.print('FPS : '..tostring(love.timer.getFPS()),Virtual_Width-50,10)
end