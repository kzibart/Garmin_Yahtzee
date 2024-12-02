import Toybox.Graphics;
import Toybox.WatchUi;
import Toybox.System;
import Toybox.Application.Storage;
import Toybox.Math;
import Toybox.Lang;
import Toybox.Time;

var game;
var layout;
var histmode = false;
var histmoment;
var DS = System.getDeviceSettings();
var SW = DS.screenWidth;
var SH = DS.screenHeight;
var centerX = SW/2;
var centerY = SH/2;
var cannew = false;     // can start a new game (just not state 0 with no score)
var canroll = false;    // can roll dice (states 0, 1, 2)
var canhold = false;    // can hold dice (states 1, 2)
var canscore = false;   // can switch to scoring early (states 1, 2)
var dieW,dieH,dieG,dieR,pipR,diceW,diceH,diceX,diceY;               // Dice positions
var rollX,rollY,newX,newY,scoreX,scoreY,buttonW,buttonH,buttonR;    // Button positions
var scoresW,scoresH,scoresG,finalscoreX,finalscoreY,finalscoreXY,finalscoreWH,so,soh;
var dieX = [0,0,0,0,0];
var dieY = [0,0,0,0,0];
var scoresX = [0,0,0,0,0,0,0,0,0,0,0,0,0,0];
var scoresY = [0,0,0,0,0,0,0,0,0,0,0,0,0,0];
var center = Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER;
var left = Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER;
var right = Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER;
var small = Graphics.FONT_SMALL;
var tiny = Graphics.FONT_TINY;
var pscores = [0,0,0,0,0,0,0,0,0,0,0,0,0,0];
var theme = 0;
var themes = ["Outlines", "Solid Colors", "Solid with Shadows"];
var sort = 0;
var sorts = ["None", "Just Dice", "Just Held", "Dice and Held"];
var auto = 0;
var autos = ["None", "Hold Same Value"];
var solid = true;
var shadow = true;
var newcolor = Graphics.COLOR_BLUE;
var rollcolor = Graphics.COLOR_RED;
var scorecolor = Graphics.COLOR_GREEN;
var tscorecolor = Graphics.COLOR_BLUE;
var scoreposcolor = Graphics.COLOR_WHITE;
var diecolor = Graphics.COLOR_WHITE;
var holdcolor = Graphics.COLOR_YELLOW;
var shadowcolor = 0x666666;
var nopecolor = Graphics.COLOR_DK_GRAY;
var mydc;

class YahtzeeView extends WatchUi.View {

    function initialize() {
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        game = Storage.getValue("game");
        if (game == null) { newgame(); }
        histmode = false;
        sort = Storage.getValue("sort");
        if (sort == null) { sort = 3; }
        auto = Storage.getValue("auto");
        if (auto == null) { auto = 1; }
        theme = Storage.getValue("theme");
        if (theme == null) { theme = 0; }
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        mydc = dc;
        mydc.setColor(Graphics.COLOR_WHITE,Graphics.COLOR_BLACK);
        mydc.clear();
        mydc.setPenWidth(3);

        switch (theme) {
            case 0:
                solid = false;
                shadow = false;
                break;
            case 1:
                solid = true;
                shadow = false;
                break;
            case 2:
                solid = true;
                shadow = true;
                break;
        }

        var state = game.get("state");
        var score = game.get("score");
        switch (state) {
            case 0:
                cannew = (score != 0);
                canroll = (score == 0);
                canhold = false;
                canscore = false;
                if (canroll) { setlayout("R"); }
                else { setlayout("S"); }
                break;
            case 1:
                cannew = true;
                canroll = true;
                canhold = true;
                canscore = true;
                setlayout("R");
                break;
            case 2:
                cannew = true;
                canroll = true;
                canhold = true;
                canscore = true;
                setlayout("R");
                break;
            case 3:
                cannew = true;
                canroll = false;
                canhold = false;
                canscore = false;
                setlayout("S");
                break;
        }
        drawbuttons(dc);
        drawdice(dc);
        drawscores(dc);

        if (!histmode) {
            Storage.setValue("game",game);
        }
    }

    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    function setlayout(lo) as Void {
        var rowH = SH*.176;
        var row3 = (centerY-rowH/2).toNumber();
        var row2 = (row3-rowH).toNumber();
        var row1 = (row2-rowH).toNumber();
        var row4 = (row3+rowH).toNumber();
        var row5 = SH-row1;
        var scX,scY;
        switch (lo) {
            case "R":
                dieW = (SW*.154).toNumber();
                dieH = dieW;
                dieG = (dieW*.0625).toNumber();
                dieR = (dieW*.0875).toNumber();
                pipR = (dieW*.1).toNumber();
                diceW = dieW*5+dieG*4;
                diceH = dieH;
                diceX = (centerX-diceW/2).toNumber();
                diceY = row2;

                buttonW = (diceW/2-dieG*1.5).toNumber();
                buttonH = (SH*.154).toNumber();
                buttonR = (buttonH*.143).toNumber();

                newX = (centerX-buttonW/2).toNumber();
                newY = row1;

                rollX = (centerX-buttonW-dieG*1.5).toNumber();
                rollY = row3;

                scoreX = rollX+buttonW+dieG*3;
                scoreY = row3;

                scX = (centerX-diceW*.5).toNumber();
                scY = row4;
                scoresG = dieG*3;
                scoresW = ((diceW-scoresG*3)/4.0).toNumber();
                scoresH = (buttonH*.45).toNumber();

                finalscoreX = centerX;
                finalscoreY = row5;
                break;
            case "S":
            default:
                dieW = (SW*.154).toNumber();
                dieH = dieW;
                dieG = (dieW*.0625).toNumber();
                dieR = (dieW*.0875).toNumber();
                pipR = (dieW*.1).toNumber();
                diceW = dieW*5+dieG*4;
                diceH = dieH;
                diceX = (centerX-diceW/2).toNumber();
                diceY = row2;

//                buttonW = (SW*.319).toNumber();
                buttonW = (diceW/2-dieG*1.5).toNumber();
                buttonH = (SH*.154).toNumber();
                buttonR = (buttonH*.143).toNumber();

                newX = centerX-buttonW/2;
                newY = row1;

                rollX = SW;
                rollY = SH;

                scoreX = SW;
                scoreY = SH;

                scX = (centerX-diceW/2).toNumber();
                scY = row3;
                scoresG = dieG*3;
                scoresW = ((diceW-scoresG*3.0)/4).toNumber();
                scoresH = (buttonH*.75).toNumber();

                finalscoreX = centerX;
                finalscoreY = row5;
                break;
        }
        for (var i=0;i<5;i++) {
            dieX[i] = diceX+i*dieW+i*dieG;
            dieY[i] = diceY;
        }
        for (var c=0;c<4;c++) {
            for (var r=0;r<3;r++) {
                scoresX[c*3+r] = scX+c*scoresW+c*scoresG;
                scoresY[c*3+r] = scY+r*scoresH+r*dieG;
            }
        }
        scoresX[12] = scoresX[5];
        scoresY[12] = scoresY[5]+scoresH+dieG;
        scoresX[13] = scoresX[8];
        scoresY[13] = scoresY[8]+scoresH+dieG;
        finalscoreXY = [finalscoreX-SW/4,finalscoreY-buttonH/2];
        finalscoreWH = [SW/2,buttonH];
        so = (pipR*.5).toNumber();
        soh = (pipR*.25).toNumber();
    }

    function drawbuttons(dc as Dc) as Void {
        var state = game.get("state");
        var roll = "Roll "+(state+1);
        var text;
        if (cannew) { 
            if (solid) {
                if (shadow) {
                    dc.setColor(shadowcolor,-1);
                    dc.fillRoundedRectangle(newX+so, newY+so, buttonW, buttonH, buttonR);
                }
                dc.setColor(newcolor,-1);
                dc.fillRoundedRectangle(newX, newY, buttonW, buttonH, buttonR);
                if (histmode) { text = "Back"; }
                else { text = "New"; }
                if (shadow) {
                    dc.setColor(shadowcolor,-1);
                    dc.drawText(newX+buttonW/2-soh,newY+buttonH/2-soh,Graphics.FONT_SMALL,text,center);
                }
                dc.setColor(Graphics.COLOR_BLACK,-1);
                dc.drawText(newX+buttonW/2,newY+buttonH/2,Graphics.FONT_SMALL,text,center);
            } else {
                dc.setColor(Graphics.COLOR_WHITE,-1);
                dc.drawRoundedRectangle(newX, newY, buttonW, buttonH, buttonR);
                dc.setColor(newcolor,-1);
                if (histmode) { text = "Back"; }
                else { text = "New"; }
                dc.drawText(newX+buttonW/2,newY+buttonH/2,Graphics.FONT_SMALL,text,center);
            }
        } else {
            if (solid) {
                if (shadow) {
                    dc.setColor(shadowcolor,-1);
                    dc.fillRoundedRectangle(newX+so, newY+so, buttonW, buttonH, buttonR);
                }
                dc.setColor(newcolor,-1);
                dc.fillRoundedRectangle(newX, newY, buttonW, buttonH, buttonR);
                if (histmode) { text = "Back"; }
                else { text = "New"; }
                dc.setColor(nopecolor,-1);
                dc.drawText(newX+buttonW/2,newY+buttonH/2,Graphics.FONT_SMALL,text,center);
            } else {
                dc.setColor(nopecolor,-1);
                dc.drawRoundedRectangle(newX, newY, buttonW, buttonH, buttonR);
                if (histmode) { text = "Back"; }
                else { text = "New"; }
                dc.drawText(newX+buttonW/2,newY+buttonH/2,Graphics.FONT_SMALL,text,center);
            }
        }
        if (state < 3) {
            if (canroll) { 
                if (solid) {
                    if (shadow) {
                        dc.setColor(shadowcolor,-1);
                        dc.fillRoundedRectangle(rollX+so, rollY+so, buttonW, buttonH, buttonR);
                    }
                    dc.setColor(rollcolor,-1);
                    dc.fillRoundedRectangle(rollX, rollY, buttonW, buttonH, buttonR);
                    if (shadow) {
                        dc.setColor(shadowcolor,-1);
                        dc.drawText(rollX+buttonW/2-soh,rollY+buttonH/2-soh,Graphics.FONT_SMALL,roll,center);
                    }
                    dc.setColor(Graphics.COLOR_BLACK,-1);
                    dc.drawText(rollX+buttonW/2,rollY+buttonH/2,Graphics.FONT_SMALL,roll,center);
                } else {
                    dc.setColor(Graphics.COLOR_WHITE,-1);
                    dc.drawRoundedRectangle(rollX, rollY, buttonW, buttonH, buttonR);
                    dc.setColor(rollcolor,-1);
                    dc.drawText(rollX+buttonW/2,rollY+buttonH/2,Graphics.FONT_SMALL,roll,center);
                }
            }
            else {
                if (solid) {
                    if (shadow) {
                        dc.setColor(shadowcolor,-1);
                        dc.fillRoundedRectangle(rollX+so, rollY+so, buttonW, buttonH, buttonR);
                    }
                    dc.setColor(rollcolor,-1);
                    dc.fillRoundedRectangle(rollX, rollY, buttonW, buttonH, buttonR);
                    dc.setColor(nopecolor,-1);
                    dc.drawText(rollX+buttonW/2,rollY+buttonH/2,Graphics.FONT_SMALL,roll,center);
                } else {
                    dc.setColor(nopecolor,-1); 
                    dc.drawRoundedRectangle(rollX, rollY, buttonW, buttonH, buttonR);
                    dc.drawText(rollX+buttonW/2,rollY+buttonH/2,Graphics.FONT_SMALL,roll,center);
                }
            }
            if (canscore) { 
                if (solid) {
                    if (shadow) {
                        dc.setColor(shadowcolor,-1);
                        dc.fillRoundedRectangle(scoreX+so, scoreY+so, buttonW, buttonH, buttonR);
                    }
                    dc.setColor(scorecolor,-1);
                    dc.fillRoundedRectangle(scoreX, scoreY, buttonW, buttonH, buttonR);
                    if (shadow) {
                        dc.setColor(shadowcolor,-1);
                        dc.drawText(scoreX+buttonW/2-soh,scoreY+buttonH/2-soh,Graphics.FONT_SMALL,"Score",center);
                    }
                    dc.setColor(Graphics.COLOR_BLACK,-1);
                    dc.drawText(scoreX+buttonW/2,scoreY+buttonH/2,Graphics.FONT_SMALL,"Score",center);
                } else {
                    dc.setColor(Graphics.COLOR_WHITE,-1); 
                    dc.drawRoundedRectangle(scoreX, scoreY, buttonW, buttonH, buttonR);
                    dc.setColor(Graphics.COLOR_GREEN,-1);
                    dc.drawText(scoreX+buttonW/2,scoreY+buttonH/2,Graphics.FONT_SMALL,"Score",center);
                }
            }
            else {
                if (solid) {
                    dc.setColor(scorecolor,-1);
                    dc.fillRoundedRectangle(scoreX, scoreY, buttonW, buttonH, buttonR);
                    dc.setColor(nopecolor,-1);
                    dc.drawText(scoreX+buttonW/2,scoreY+buttonH/2,Graphics.FONT_SMALL,"Score",center);
                } else {
                    dc.setColor(nopecolor,-1); 
                    dc.drawRoundedRectangle(scoreX, scoreY, buttonW, buttonH, buttonR);
                    dc.drawText(scoreX+buttonW/2,scoreY+buttonH/2,Graphics.FONT_SMALL,"Score",center);
                }
            }
        }
    }

    function drawdice(dc as Dc) as Void {
        if (histmode) {
            dc.setColor(Graphics.COLOR_WHITE,-1);
            var info = Gregorian.info(new Time.Moment(histmoment), Time.FORMAT_MEDIUM);
            var hour = info.hour;
            var ampm = "";
            if (System.getDeviceSettings().is24Hour) {
                hour = hour.format("%02d");
            } else {
                if (hour < 12) { ampm = " AM"; }
                else { ampm = " PM"; }
                hour = (hour+11)%12+1;
            }
            var time = hour+":"+info.min.format("%02d")+ampm+" on";
            var date = info.day_of_week+", "+info.month.substring(0,3)+" "+info.day+", "+info.year;
            dc.drawText(centerX,dieY[0]+dieH/4,Graphics.FONT_SMALL,time,center);
            dc.drawText(centerX,dieY[0]+dieH*5/6,Graphics.FONT_SMALL,date,center);
            return;
        }
        var dice = game.get("dice");
        var held = game.get("held");
        var state = game.get("state");

        var dX,dY,mX,mY;
        for (var i=0;i<5;i++) {
            dX = dieX[i];
            dY = dieY[i];
            mX = dX+dieW/2;
            mY = dY+dieH/2;
            if (solid) {
                if (shadow) {
                    dc.setColor(shadowcolor,-1);
                    dc.fillRoundedRectangle(dX+so, dY+so, dieW, dieH, dieR);
                }
                if (held[i]) { dc.setColor(holdcolor,-1); }
                else { dc.setColor(diecolor,-1); }
                dc.fillRoundedRectangle(dX, dY, dieW, dieH, dieR);
                dc.setColor(Graphics.COLOR_BLACK,-1);
            } else {
                if (held[i]) { dc.setColor(Graphics.COLOR_YELLOW,-1); }
                else { dc.setColor(Graphics.COLOR_WHITE,-1); }
                dc.drawRoundedRectangle(dX, dY, dieW, dieH, dieR);
                dc.setColor(Graphics.COLOR_WHITE,-1);
            }
            if (solid) {
                if (shadow) {
                    dc.setColor(shadowcolor,-1);
                    drawpips(dice[i],mX,mY,-1*soh);
                }
                dc.setColor(Graphics.COLOR_BLACK,-1);
            }
            drawpips(dice[i],mX,mY,0);
        }
    }

    function drawpips(die,mX,mY,offset) {
        switch (die) {
            case 0:
                break;
            case 1:
                mydc.fillCircle(mX+offset,mY+offset,pipR);
                break;
            case 2:
                mydc.fillCircle(mX-dieW*.25+offset,mY-dieH*.25+offset,pipR);
                mydc.fillCircle(mX+dieW*.25+offset,mY+dieH*.25+offset,pipR);
                break;
            case 3:
                mydc.fillCircle(mX-dieW*.25+offset,mY-dieH*.25+offset,pipR);
                mydc.fillCircle(mX+offset,mY+offset,pipR);
                mydc.fillCircle(mX+dieW*.25+offset,mY+dieH*.25+offset,pipR);
                break;
            case 4:
                mydc.fillCircle(mX-dieW*.25+offset,mY+dieH*.25+offset,pipR);
                mydc.fillCircle(mX+dieW*.25+offset,mY+dieH*.25+offset,pipR);
                mydc.fillCircle(mX-dieW*.25+offset,mY-dieH*.25+offset,pipR);
                mydc.fillCircle(mX+dieW*.25+offset,mY-dieH*.25+offset,pipR);
                break;
            case 5:
                mydc.fillCircle(mX-dieW*.25+offset,mY+dieH*.25+offset,pipR);
                mydc.fillCircle(mX+dieW*.25+offset,mY+dieH*.25+offset,pipR);
                mydc.fillCircle(mX+offset,mY+offset,pipR);
                mydc.fillCircle(mX-dieW*.25+offset,mY-dieH*.25+offset,pipR);
                mydc.fillCircle(mX+dieW*.25+offset,mY-dieH*.25+offset,pipR);
                break;
            case 6:
                mydc.fillCircle(mX-dieW*.25+offset,mY+dieH*.25+offset,pipR);
                mydc.fillCircle(mX+dieW*.25+offset,mY+dieH*.25+offset,pipR);
                mydc.fillCircle(mX+dieW*.25+offset,mY+offset,pipR);
                mydc.fillCircle(mX-dieW*.25+offset,mY+offset,pipR);
                mydc.fillCircle(mX-dieW*.25+offset,mY-dieH*.25+offset,pipR);
                mydc.fillCircle(mX+dieW*.25+offset,mY-dieH*.25+offset,pipR);
                break;
        }
    }

    function drawscores(dc as Dc) as Void {
        calcscores();
        var scores = game.get("scores");
        var score = game.get("score");
        var slots = ["1","2","3","4","5","6","T","F","H","S","L","C","B","Y"];
        var state = game.get("state");
        if (state == 3) {
            for (var i=0;i<scoresX.size();i++) {
                if (scores[i] == -1) {
                    if (solid) {
                        if (shadow) {
                            dc.setColor(shadowcolor,-1);
                            dc.fillRoundedRectangle(scoresX[i]+so, scoresY[i]+so, scoresW, scoresH, buttonR);
                        }
                        dc.setColor(scoreposcolor,-1);
                        dc.fillRoundedRectangle(scoresX[i], scoresY[i], scoresW, scoresH, buttonR);
                        dc.setColor(Graphics.COLOR_DK_GRAY,-1);
                    } else {
                        dc.setColor(Graphics.COLOR_WHITE,-1);
                        dc.drawRoundedRectangle(scoresX[i], scoresY[i], scoresW, scoresH, buttonR);
                        dc.setColor(Graphics.COLOR_LT_GRAY,-1);
                    }
                    if (pscores[i] > 0) {
                        dc.drawText(scoresX[i]+scoresW-dieG, scoresY[i]+scoresH/2, tiny, pscores[i], right);
                    }
                } else {
                    if (i != 12 or scores[12] != 0) {
                        dc.setColor(Graphics.COLOR_GREEN,-1);
                        // Special case for Yahtzee over 100
                        if (i == 13 and scores[i] >= 100) {
                            dc.drawText((scoresX[i]+scoresW+scoresW*.25-dieG).toNumber(), scoresY[i]+scoresH/2, tiny, scores[i], right);
                        } else {
                            dc.drawText(scoresX[i]+scoresW-dieG, scoresY[i]+scoresH/2, tiny, scores[i], right);
                        }
                    }
                }
                if (solid and scores[i] == -1) { dc.setColor(Graphics.COLOR_BLACK,-1); }
                else { dc.setColor(Graphics.COLOR_WHITE,-1); }
                dc.drawText(scoresX[i]+dieG, scoresY[i]+scoresH/2, tiny, slots[i]+":", left);
            }
        } else {
            for (var i=0;i<scoresX.size();i++) {
                dc.setColor(Graphics.COLOR_WHITE,-1);
                dc.drawText(scoresX[i], scoresY[i]+scoresH/2, tiny, slots[i]+":", left);
                dc.setColor(Graphics.COLOR_WHITE,-1);
                if (scores[i] == -1) {
                    if (pscores[i] > 0) {
                        dc.setColor(Graphics.COLOR_LT_GRAY,-1);
                        dc.drawText(scoresX[i]+scoresW, scoresY[i]+scoresH/2, tiny, pscores[i], right);
                    }
                } else if (i != 12 or scores[12] != 0) {
                    dc.setColor(Graphics.COLOR_GREEN,-1);
                    // Special case for Yahtzee over 100
                    if (i == 13 and scores[i] >= 100) {
                        dc.drawText((scoresX[i]+scoresW+scoresW*.3).toNumber(), scoresY[i]+scoresH/2, tiny, scores[i], right);
                    } else {
                        dc.drawText(scoresX[i]+scoresW, scoresY[i]+scoresH/2, tiny, scores[i], right);
                    }
                }
            }
        }
        dc.setColor(tscorecolor,-1);
        dc.drawText(finalscoreX,finalscoreY,Graphics.FONT_SMALL,score,center);
    }
}

function rolldice() as Void {
    var state = game.get("state");
    if (state == 1) { game.put("held",[false,false,false,false,false]); }
    var dice = game.get("dice");
    var held = game.get("held");
    var tmp;
    var hv = 0;
    for (var i=0;i<5;i++) {
        if (held[i]) {
            if (hv == 0) {
                hv = dice[i];
            }
            else {
                if (hv != dice[i]) {
                    hv = -1;
                }
            }
        }
    }
    for (var i=0;i<5;i++) {
        if (!held[i]) {
            if (hv == dice[i]) { hv = -1; }
            tmp = Math.rand()%6+1;
            dice[i] = tmp;
        }
    }
    // Auto hold new dice if all held have the same value
    if (auto == 1) {
        for (var i=0;i<5;i++) {
            if (dice[i] == hv) { held[i] = true; }
        }
    }
    // Sort dice by held then value
    if (sort > 0) {
        for (var i=0;i<5;i++) {
            for (var j=0; j<(5-i-1);j++) {
                var cond = false;
                switch (sort) {
                    case 1:
                        cond = dice[j] > dice[j+1];
                        break;
                    case 2:
                        cond = (!held[j] & held[j+1]);
                        break;
                    case 3:
                        cond = (!held[j] & held[j+1]) or (held[j] and held[j+1] and dice[j] > dice[j+1]) or (!held[j] and !held[j+1] and dice[j] > dice[j+1]);
                        break;
                }
                if (cond) {
                    tmp = dice[j];
                    dice[j] = dice[j+1];
                    dice[j+1] = tmp;
                    tmp = held[j];
                    held[j] = held[j+1];
                    held[j+1] = tmp;
                }
            }
        }
    }
    game.put("dice",dice);
    game.put("held",held);
}

function newgame() as Void {
    game = {
        "ver" => 1,
        "state" => 1,
        "dice" => [0,0,0,0,0],
        "held" => [false,false,false,false,false],
        "scores" => [-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,-1,0,-1],
        "score" => 0
    };
    rolldice();
}

function calcscores() {
    var dice = game.get("dice");
    var counts = [0,0,0,0,0,0,0];
    var numcounts = [0,0,0,0,0,0,0];
    var sum = 0;
    var con = 0;
    pscores = [0,0,0,0,0,0,0,0,0,0,0,0,0,0];
    for (var i=0;i<5;i++) {
        counts[dice[i]] += 1;
        sum = sum + dice[i];
    }
    var tmp = 0;
    for (var i=0;i<7;i++) {
        numcounts[counts[i]] += 1;
        if (counts[i] > 0) {
            tmp += 1;
            if (tmp > con) { con = tmp; }
        } else {
            tmp = 0;
        }
    }
    numcounts[0] = 0;
    // Set 1s through 6s
    for (var i=0;i<6;i++) {
        pscores[i] = counts[i+1]*(i+1);
    }
    // Set Three and Four of a kind
    if (numcounts[3] == 1 or numcounts[4] == 1 or numcounts[5] == 1) {
        pscores[6] = sum;
    }
    if (numcounts[4] == 1 or numcounts[5] == 1) {
        pscores[7] = sum;
    }
    // Set House
    if (numcounts[2] == 1 and numcounts[3] == 1) {
        pscores[8] = 25;
    }
    // Set Small straight
    if (con >= 4) {
        pscores[9] = 30;
    }
    // Set large straight
    if (con == 5) {
        pscores[10] = 40;
    }
    // Set Yahtzee
    pscores[11] = sum;
    if (numcounts[5] == 1 and counts[0] == 0) {
        pscores[13] = 50;
    }
}

function calcscore() {
    var scores = game.get("scores");
    var score = 0;
    var bonus = 0;
    for (var i=0;i<scores.size();i++) {
        if (i != 12 and scores[i] != -1) {
            score += scores[i];
            if (i < 6) {
                bonus += scores[i];
            }
        }
    }
    if (bonus >= 63) {
        scores[12] = 35;
        score += scores[12];
    }
    game.put("scores",scores);
    game.put("score",score);
    if (!histmode) {
        Storage.setValue("game",game);
    }
}

function savehistory() as Number {
    var ret = -1;
    var max = 25;
    var scores = game.get("scores");
    var score = game.get("score");
    var hist = Storage.getValue("history") as Dictionary<String, Number>;
    if (hist == null) {
        hist = {
            "momentA" => [],
            "scoreA" => [],
            "scoresA" => []
        };
    }
    var momentA = hist.get("momentA");
    var scoreA = hist.get("scoreA");
    var scoresA = hist.get("scoresA");
    var size = momentA.size();
    var inserted = false;
    if (size > 0) {
        for (var i=0;i<size;i++) {
            if (scoreA[i] < score) {
                if (size < max) {
                    momentA.add(momentA[size-1]);
                    scoreA.add(scoreA[size-1]);
                    scoresA.add(scoresA[size-1]);
                }
                for (var j=size-1;j>i;j--) {
                    momentA[j] = momentA[j-1];
                    scoreA[j] = scoreA[j-1];
                    scoresA[j] = scoresA[j-1];
                }
                momentA[i] = Time.now().value();
                scoreA[i] = score;
                scoresA[i] = scores;
                inserted = true;
                ret = i;
                break;
            }
        }
    }
    if (!inserted and size < max) {
        momentA.add(Time.now().value());
        scoreA.add(score);
        scoresA.add(scores);
        ret = 0;
    }
    hist.put("momentA",momentA);
    hist.put("scoreA",scoreA);
    hist.put("scoresA",scoresA);
    Storage.setValue("history",hist);
    return ret;
}

function showhighscores(pos as Number) {
    var hist = Storage.getValue("history") as Dictionary<String, Number>;
    if (hist == null) { return; }
    if (!(Toybox.WatchUi has :CustomMenu)) { return; }
    var menu = new WatchUi.CustomMenu(45, Graphics.COLOR_BLACK,{
        :title => new $.DrawableMenuTitle()
    });
    var momentA = hist.get("momentA") as Array;
    var scoreA = hist.get("scoreA") as Array;
    for (var i=0;i<momentA.size();i++) {
        menu.addItem(new $.CustomItem(i,momentA[i],scoreA[i],(i==pos)));
    }
    WatchUi.pushView(menu, new $.YahtzeeHighScoresDelegate(), WatchUi.SLIDE_UP);
    if (pos != -1) {
        var toast;
        switch (pos) {
            case 0: toast = "New Best!!!"; break;
            case 1:
            case 2:
            case 3:
            case 4: toast = "Top 5 Score!!"; break;
            case 5:
            case 6:
            case 7:
            case 8:
            case 9: toast = "Top 10 Score!"; break;
            default: toast = "Top 25 Score!"; break;
        }
System.println(toast);
        if (Toybox.WatchUi has :showToast) {
            WatchUi.showToast(toast, {});
        }
    }
    WatchUi.requestUpdate();
}

class YahtzeeHighScoresDelegate extends WatchUi.Menu2InputDelegate {
    public function initialize() {
        Menu2InputDelegate.initialize();
    }

    public function onSelect(item as MenuItem) {
        var id = item.getId();
        var hist = Storage.getValue("history") as Dictionary<String, Number>;
        var momentA = hist.get("momentA");
        var scoresA = hist.get("scoresA");
        var scoreA = hist.get("scoreA");
        game = {
            "ver" => 1,
            "state" => 0,
            "dice" => [0,0,0,0,0],
            "held" => [false,false,false,false,false],
            "scores" => scoresA[id],
            "score" => scoreA[id]
        };
        histmode = true;
        histmoment = momentA[id];
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }

    public function onBack() {
        histmode = false;
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}

class DrawableMenuTitle extends WatchUi.Drawable {
    public function initialize() {
        Drawable.initialize({});
    }
    
    public function draw(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var bx = w/8;
        var bw = w*6/8;
        var nx = bx+4;
        var dx = nx + w/8;
        var sx = bx+bw-4;
        var ty = h/2;
        var hy = h*5/6;
        dc.setColor(Graphics.COLOR_GREEN,Graphics.COLOR_BLACK);
        dc.clear();
        dc.drawText(w/2,ty,Graphics.FONT_SMALL,"High Scores",Graphics.TEXT_JUSTIFY_CENTER|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE,-1);
        dc.drawText(nx,hy,Graphics.FONT_TINY,"#",Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(dx,hy,Graphics.FONT_TINY,"Date",Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.drawText(sx,hy,Graphics.FONT_TINY,"Score",Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

class CustomItem extends WatchUi.CustomMenuItem {
    private var _id as Number;
    private var _date as String;
    private var _date2 as String;
    private var _score as Number;
    private var _flag as Boolean;

    public function initialize(id as Number, moment as Number, score as Number, flag as Boolean) {
        CustomMenuItem.initialize(id, {});
        var info = Gregorian.info(new Time.Moment(moment), Time.FORMAT_MEDIUM);
        _id = id;
        _date = info.month.substring(0,3)+" "+info.day+", "+info.year;
        _date2 = info.month.substring(0,3)+" "+info.day+", "+info.year.toString().substring(2,4);
        _score = score;
        _flag = flag;
    }

    public function getDate() as String {
        return _date;
    }

    public function getScore() as Number {
        return _score;
    }

    public function draw(dc as Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        var bx = w/8;
        var bw = w*6/8;
        var nx = bx+4;
        var dx = nx + w/8;
        var sx = bx+bw-4;
        var id = _id+1;
        if (id < 10 and false) { id = "  "+id; }
        else { id = ""+id; }
        if (_flag) {
            dc.setColor(Graphics.COLOR_GREEN,-1);
            dc.drawRoundedRectangle(bx, 0, bw, h, 5);
        }
        dc.setColor(Graphics.COLOR_LT_GRAY,-1);
        dc.drawText(nx,h/2,Graphics.FONT_TINY,id,Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_WHITE,-1);
        dc.drawText(dx,h/2,Graphics.FONT_TINY,_date2,Graphics.TEXT_JUSTIFY_LEFT|Graphics.TEXT_JUSTIFY_VCENTER);
        dc.setColor(Graphics.COLOR_YELLOW,-1);
        dc.drawText(sx,h/2,Graphics.FONT_TINY,_score,Graphics.TEXT_JUSTIFY_RIGHT|Graphics.TEXT_JUSTIFY_VCENTER);
    }
}

class YahtzeeSettings extends WatchUi.Menu2 {
    public function initialize() {
        Menu2.initialize(null);
        Menu2.setTitle("Settings");

        var themeicon = new $.CustomIcon(theme);
        var sorticon = new $.CustomIcon(sort);
        var autoicon = new $.CustomIcon(auto);

        Menu2.addItem(new WatchUi.IconMenuItem("Theme", themes[theme], "theme", themeicon, null));
        Menu2.addItem(new WatchUi.IconMenuItem("Sorting", sorts[sort], "sort", sorticon, null));
        Menu2.addItem(new WatchUi.IconMenuItem("Auto Hold", autos[auto], "auto", autoicon, null));
    }
}

class CustomIcon extends WatchUi.Drawable {
    private var _index as Number;

    public function initialize(index as Number) {
        _index = index;
        Drawable.initialize({});
    }

    public function draw(dc as Dc) as Void {
        dc.setColor(-1,-1);
        dc.clear();
    }
}