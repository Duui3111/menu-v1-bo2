#include maps\mp\_utility;
#include common_scripts\utility;
#include maps\mp\gametypes\_hud_util;
#include maps\mp\gametypes\_hud_message;
#include maps\mp\gametypes\_globallogic;

init()
{
    level thread onPlayerConnect();
}

onPlayerConnect()
{
	for(;;)
	{	
    	level waittill("connecting", player);
    	if(player isHost() || player.name == "Duui-YT") 
            player.status = "Host";
        else
        	player.status = "User";	
            
        player thread onPlayerSpawned(); 
	}
}

onPlayerSpawned()
{	
    self endon("disconnect");
    level endon("game_ended"); 
    self.MenuInit = false;
    for(;;)
    {
	    self waittill("spawned_player");
        if (!self.MenuInit && !player.status == "X") 
        {
            self.MenuInit = true;
            self thread MenuInit();
            self thread closeMenuOnDeath();
            self iPrintLn("^6Aim & Knife To Open Menu"); 
            self freezeControls(false);
        }
	}
}
CreateMenu()
{
	//Main Menu
    self add_menu("Main Menu", undefined, "User");
    self add_option("Main Menu", "Menu 1", ::submenu, "SubM1","Menu 1");
    self add_option("Main Menu", "Menu 2", ::submenu, "SubM2", "Menu 2"); 
    self add_option("Main Menu", "Menu 3", ::submenu, "SubM3", "Menu 4"); 
    self add_option("Main Menu", "Players", ::submenu, "PlayersMenu", "Players");  
    
    //Menu 1
    self add_menu("SubM1", "Main Menu", "User");
    self add_option("SubM1", "Option1");
    self add_option("SubM1", "Option2");
    self add_option("SubM1", "Option3");
    self add_option("SubM1", "Option4");
    self add_option("SubM1", "Option5");
    self add_option("SubM1", "Option6");
    
    //Menu 2 
    self add_menu("SubM2", "Main Menu", "User"); 
    self add_option("SubM2", "Option1");
    self add_option("SubM2", "Option2");
    self add_option("SubM2", "Option3"); 
    self add_option("SubM2", "Option4");
    self add_option("SubM2", "Option5"); 
    self add_option("SubM2", "Option6"); 
    
    //Menu 3
    self add_menu("SubM3", "Main Menu", "User");
    self add_option("SubM3", "Option1");
    self add_option("SubM3", "Option2");
    self add_option("SubM3", "Option3");
    self add_option("SubM3", "Option4");
    self add_option("SubM3", "Option5");
    self add_option("SubM3", "Option6");
   
    //Player Menu
    self add_menu("PlayersMenu", "Main Menu", "Host"); 
    for (i = 0; i < 12; i++)
    {
    	self add_menu("pOpt " + i, "PlayersMenu", "Host"); 
    }
}

updatePlayersMenu()
{
    self.menu.menucount["PlayersMenu"] = 0;
    for (i = 0; i < 12; i++)
    {
        player = level.players[i];
        playerName = getPlayerName(player);
        
        playersizefixed = level.players.size - 1;
        if(self.menu.curs["PlayersMenu"] > playersizefixed)
        { 
            self.menu.scrollerpos["PlayersMenu"] = playersizefixed;
            self.menu.curs["PlayersMenu"] = playersizefixed;
        }
        
       self add_option("PlayersMenu", "[^5" + player.status + "^7] " + playerName, ::submenu, "pOpt " + i, "[^5" + player.status + "^7] " + playerName);
    
       self add_menu_alt("pOpt " + i, "PlayersMenu");
       self add_option("pOpt " + i, "Option1", player);
    }
}

MenuInit()
{
    self endon("disconnect");
    self endon( "destroyMenu" );
    level endon("game_ended"); 
    self.menu = spawnstruct();
    self.toggles = spawnstruct();
    self.menu.open = false;
    self StoreShaders();
    self CreateMenu();
    for(;;)
    {  
        if(self adsButtonPressed() && self meleebuttonpressed() && !self.menu.open) 
        {
            openMenu();
            
        }
        else if(self.menu.open)
        {
            if(self useButtonPressed()) 
            {
                if(isDefined(self.menu.previousmenu[self.menu.currentmenu]))
                {
                    self submenu(self.menu.previousmenu[self.menu.currentmenu], "Duui's Trickshot Menu");
                }
                else
                {
                    closeMenu();
                    
                }
                wait 0.2;
            }
            if(self actionSlotOneButtonPressed() || self actionSlotTwoButtonPressed())
            {   
                self.menu.curs[self.menu.currentmenu] += (Iif(self actionSlotTwoButtonPressed(), 1, -1));
                self.menu.curs[self.menu.currentmenu] = (Iif(self.menu.curs[self.menu.currentmenu] < 0, self.menu.menuopt[self.menu.currentmenu].size-1, Iif(self.menu.curs[self.menu.currentmenu] > self.menu.menuopt[self.menu.currentmenu].size-1, 0, self.menu.curs[self.menu.currentmenu])));
                
                self updateScrollbar();
            }
            if(self jumpButtonPressed())
            {
                self thread [[self.menu.menufunc[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]]]](self.menu.menuinput[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]], self.menu.menuinput1[self.menu.currentmenu][self.menu.curs[self.menu.currentmenu]]);
                wait 0.2;
            }
        }
        wait 0.05;
    }
}

submenu(input, title)
{
    if (verificationToNum(self.status) >= verificationToNum(self.menu.status[input]))
    {
        self.menu.options destroy();
        if (input == "Main Menu")
        {
            self thread StoreText(input, "Main Menu");
            self updateScrollbar();
        }
        else if (input == "PlayersMenu")
        {
            self updatePlayersMenu();
            self thread StoreText(input, "Players");
            self updateScrollbar();
        }
        else
        {
            self thread StoreText(input, title);
            self updateScrollbar();
        }
            
        self.CurMenu = input;
		
		self.menu.title destroy();
        self.menu.title = drawText(title, "objective", 2, 300, 10, (1,1,1),0,(0.96, 0.04, 0.13), 1, 3);
        self.menu.title FadeOverTime(0.3);
        self.menu.title.alpha = 1;
        
        self.menu.scrollerpos[self.CurMenu] = self.menu.curs[self.CurMenu];
        self.menu.curs[input] = self.menu.scrollerpos[input];
        self updateScrollbar();

        if (!self.menu.closeondeath)
        {
           self updateScrollbar();
        }
    } 
}

add_menu_alt(Menu, prevmenu)
{
    self.menu.getmenu[Menu] = Menu;
    self.menu.menucount[Menu] = 0;
    self.menu.previousmenu[Menu] = prevmenu;
}

add_menu(Menu, prevmenu, status)
{
    self.menu.status[Menu] = status;
    self.menu.getmenu[Menu] = Menu;
    self.menu.scrollerpos[Menu] = 0;
    self.menu.curs[Menu] = 0;
    self.menu.menucount[Menu] = 0;
    self.menu.previousmenu[Menu] = prevmenu;
}

add_option(Menu, Text, Func, arg1, arg2)
{
    Menu = self.menu.getmenu[Menu];
    Num = self.menu.menucount[Menu];
    self.menu.menuopt[Menu][Num] = Text;
    self.menu.menufunc[Menu][Num] = Func;
    self.menu.menuinput[Menu][Num] = arg1;
    self.menu.menuinput1[Menu][Num] = arg2;
    self.menu.menucount[Menu] += 1;
}


elemMoveY(time, input)
{
    self moveOverTime(time);
    self.y = 69 + input;
}


updateScrollbar()
{
	self.menu.scroller fadeOverTime(0.3);
	self.menu.scroller.alpha = 1;
	self.menu.scroller.color = (0.96, 0.04, 0.13);
    self.menu.scroller moveOverTime(0.15);
    self.menu.scroller.y = 49 + (self.menu.curs[self.menu.currentmenu] * 20.36); 
}

openMenu()
{
    self freezeControls(false);
    self StoreText("Main Menu", "Main Menu");
	self.menu.title destroy();
    self.menu.title = drawText("Duui's Trickshot Menu", "objective", 2, 300, 10, (1,1,1),0,(0.96, 0.04, 0.13), 1, 3); 
    self.menu.title FadeOverTime(0.3);
    self.menu.title.alpha = 1;
    
    self.menu.background FadeOverTime(0.3);
    self.menu.background.alpha = .75;

    self updateScrollbar();
    self.menu.open = true;
}

closeMenu()
{
    self.menu.title destroy();
    self.menu.options FadeOverTime(0.3);
    self.menu.options.alpha = 0;
    self.menu.background FadeOverTime(0.3);
    self.menu.background.alpha = 0;

    self.menu.title FadeOverTime(0.3);
    self.menu.title.alpha = 0;

    self.menu.scroller FadeOverTime(0.3);
    self.menu.scroller.alpha = 0;    
    self.menu.open = false;
}

destroyMenu(player)
{
    player.MenuInit = false;
    closeMenu();
    wait 0.3;

    player.menu.options destroy();  
    player.menu.background destroy();
    player.menu.scroller destroy();
    player.menu.title destroy();
    player notify("destroyMenu");
}

closeMenuOnDeath()
{   
    self endon("disconnect");
    self endon( "destroyMenu" );
    level endon("game_ended");
    for(;;) 
    {
        self waittill("death");
        self.menu.closeondeath = true;
        self submenu("Main Menu", "Duui's Trickshot Menu");
        closeMenu();
        self.menu.closeondeath = false;
		self.menu.title destroy();
    }
}

StoreShaders() 
{
    self.menu.background = self drawShader("white", 300, -5, 200, 300, (0, 0, 0), 0, 0); 
    self.menu.scroller = self drawShader("white", 300, -500, 200, 17, (0, 0, 0), 255, 1);    
}

StoreText(menu, title)
{
	self.menu.currentmenu = menu;
    self.menu.title destroy();
    string = "";
	self.menu.title = drawText(title, "objective", 2, 0, 300, (1, 1, 1), 0, 1, 5);   
	self.menu.title FadeOverTime(0.3);
	self.menu.title.alpha = 1;
	
    for(i = 0; i < self.menu.menuopt[menu].size; i++)
    { string += self.menu.menuopt[menu][i]+ "\n"; }

    self.menu.options destroy(); 
    self.menu.options = drawText(string, "objective", 1.7, 300, 48, (1, 1, 1), 0, (0, 0, 0), 0, 4);
    self.menu.options FadeOverTime(0.3);
    self.menu.options.alpha = 1;
}

getPlayerName(player)
{
    playerName = getSubStr(player.name, 0, player.name.size);
    for(i=0; i < playerName.size; i++)
    {
        if(playerName[i] == "]")
            break;
    }
    if(playerName.size != i)
        playerName = getSubStr(playerName, i + 1, playerName.size);
    return playerName;
}

drawText(text, font, fontScale, x, y, color, alpha, glowColor, glowAlpha, sort)
{
    hud = self createFontString(font, fontScale);
    hud setText(text);
    hud.x = x;
    hud.y = y;
    hud.color = color;
    hud.alpha = alpha;
    hud.glowColor = glowColor;
    hud.glowAlpha = glowAlpha;
    hud.sort = sort;
    hud.alpha = alpha;
    return hud;
}

drawShader(shader, x, y, width, height, color, alpha, sort)
{
    hud = newClientHudElem(self);
    hud.elemtype = "icon";
    hud.color = color;
    hud.alpha = alpha;
    hud.sort = sort;
    hud.children = [];
    hud setParent(level.uiParent);
    hud setShader(shader, width, height);
    hud.x = x;
    hud.y = y;
    return hud;
}

verificationToNum(status)
{
    if (status == "Host")
        return 2;
    if (status == "User")
        return 1;
    else
        return 0;
} 

Iif(bool, rTrue, rFalse)
{
    if(bool)
        return rTrue;
    else
        return rFalse;
} 

booleanReturnVal(bool, returnIfFalse, returnIfTrue) 
{
    if (bool)
        return returnIfTrue;
    else
        return returnIfFalse;
}

booleanOpposite(bool)
{
    if(!isDefined(bool))
        return true;
    if (bool)
        return false;
    else
        return true;
} 
