import Toybox.Lang;
import Toybox.WatchUi;

class YahtzeeDelegate extends WatchUi.BehaviorDelegate {

    function initialize() {
        BehaviorDelegate.initialize();
    }

    function onMenu() as Boolean {
        WatchUi.pushView(new YahtzeeSettings(), new YahtzeeMenuDelegate(), WatchUi.SLIDE_UP);
        return true;
    }

    function onTap(clickEvent) as Boolean {
        var xy = clickEvent.getCoordinates();
        if (histmode) {
            if (inbox([newX,newY],[buttonW,buttonH],xy)) {
                showhighscores(-1);
                return true;
            }
        }
        var state = game.get("state");
        var scores = game.get("scores");
        if (inbox([newX,newY],[buttonW,buttonH],xy)) {
            newgame();
            WatchUi.requestUpdate();
            return true;
        }
        if (canroll & inbox([rollX,rollY],[buttonW,buttonH],xy)) {
            if (state == 0) { newgame(); }
            state += 1;
            game.put("state",state);
            rolldice();
            WatchUi.requestUpdate();
            return true;
        }
        if (canscore & inbox([scoreX,scoreY],[buttonW,buttonH],xy)) {
            state = 3;
            game.put("state",state);
            WatchUi.requestUpdate();
            return true;
        }
        if (canhold) {
            var held = game.get("held");
            for (var i=0;i<5;i++) {
                if (inbox([dieX[i],dieY[i]],[dieW,dieH],xy)) {
                    held[i] = !held[i];
                    game.put("held",held);
                    WatchUi.requestUpdate();
                    return true;
                }
            }
        }
        if (state == 3) {
            var remaining = scores.size();
            for (var i=0;i<scores.size();i++) {
                if (scores[i] != -1) {
                    remaining -= 1;
                }
            }
            for (var i=0;i<scores.size();i++) {
                if (scores[i] == -1) {
                    if (inbox([scoresX[i],scoresY[i]],[scoresW,scoresH],xy)) {
                        if (scores[13] > 0 and pscores[13] == 50) {
                            scores[13] += 100;
                        }
                        scores[i] = pscores[i];
                        game.put("scores",scores);
                        calcscore();
                        if (remaining > 1) {
                            state = 1;
                            game.put("state",state);
                            rolldice();
                        } else {
                            state = 0;
                            game.put("state",state);
                            var pos = savehistory();
                            if (pos != -1) {
                                showhighscores(pos);
                            }
                        }
                        WatchUi.requestUpdate();
                        return true;
                    }
                }
            }
        }
        if (inbox(finalscoreXY,finalscoreWH,xy)) {
            showhighscores(-1);
        }
        return false;
    }

    // Check if a point is within a box
    // boxxy = [x,y] coordinates of upper left corner of box
    // boxwh = [w,h] width and height of box
    // point = [x,y] coordinates of point to check
    function inbox(boxxy,boxwh,point) as Boolean {
        if (point[0]<boxxy[0]) {return false;}
        if (point[0]>boxxy[0]+boxwh[0]) {return false;}
        if (point[1]<boxxy[1]) {return false;}
        if (point[1]>boxxy[1]+boxwh[1]) {return false;}
        return true;
    }
}