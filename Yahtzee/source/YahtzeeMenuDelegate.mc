import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Application.Storage;

class YahtzeeMenuDelegate extends WatchUi.MenuInputDelegate {

    function initialize() {
        MenuInputDelegate.initialize();
    }

    public function onSelect(item as MenuItem) {
        switch (item.getId()) {
            case "theme":
                theme = (theme + 1) % themes.size();
                Storage.setValue("theme",theme);
                item.setSubLabel(themes[theme]);
                break;
            case "sort":
                sort = (sort + 1) % sorts.size();
                Storage.setValue("sort",sort);
                item.setSubLabel(sorts[sort]);
                break;
            case "auto":
                auto = (auto + 1) % autos.size();
                Storage.setValue("auto",auto);
                item.setSubLabel(autos[auto]);
                break;
        }
    }

    public function onBack() {
        WatchUi.popView(WatchUi.SLIDE_DOWN);
    }
}