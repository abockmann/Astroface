import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.WatchUi;
import Toybox.Activity;
import Toybox.Application;
import Toybox.Time;

class Mytest3View extends WatchUi.WatchFace {

    var sc;
    var DAY_IN_ADVANCE;
    var now;
    var lastLoc;

    function initialize() {
        WatchFace.initialize();
        DAY_IN_ADVANCE = 0;
        sc = new SunCalc();
        lastLoc = null;
    }

    // Load your resources here
    function onLayout(dc as Dc) as Void {
        setLayout(Rez.Layouts.WatchFace(dc));
    }

    // Called when this View is brought to the foreground. Restore
    // the state of this View and prepare it to be shown. This includes
    // loading resources into memory.
    function onShow() as Void {
    }

    // Update the view
    function onUpdate(dc as Dc) as Void {
        // Called every minute
        var clockTime = System.getClockTime();
        var timeString = Lang.format("$1$:$2$", [clockTime.hour, clockTime.min.format("%02d")]);
        var view = View.findDrawableById("TimeLabel") as Text;
        //view.setText(timeString);
        // call solar calc by
        // sc.calculate(now, loc[0], loc[1], SUNRISE);
        // get gps coordinate
        var long = 0.1;
        var lat = 0.1;
        var app = Application.getApp();
        app.setProperty("lat", lat);
        app.setProperty("long", long);
        var curLoc = Activity.getActivityInfo().currentLocation;
        if (curLoc != null) {
          long = curLoc.toDegrees()[1].toFloat();
          lat = curLoc.toDegrees()[0].toFloat();
          // persistent storage; currentLocation is not stored forever
          app.setProperty("lat", lat);
          app.setProperty("long", long);
          }
        lat = app.getProperty("lat");
        long = app.getProperty("long");
        var coordString = Lang.format("$1$ : $2$", [lat.format("%05d"), long.format("%05d")]);
        //var view = View.findDrawableById("TimeLabel") as Text;

        view.setText(coordString);

        var view2 = View.findDrawableById("SecondsLabel") as Text;
        var secondsString = clockTime.sec.format("%02d");
        view2.setText(secondsString);

        // Call the parent onUpdate function to redraw the layout
        View.onUpdate(dc);
    }


    // Called when this View is removed from the screen. Save the
    // state of this View here. This includes freeing resources from
    // memory.
    function onHide() as Void {
    }

    // The user has just looked at their watch. Timers and animations may be started here.
    function onExitSleep() as Void {
    }

    // Terminate any active timers and prepare for slow updates.
    function onEnterSleep() as Void {
    }

    function getMoment(what) {
        var day = DAY_IN_ADVANCE;
        if (what > ASTRO_DUSK) {
            day++;
            what = ASTRO_DAWN;
        }
        now = Time.now();
        // for testing now = new Time.Moment(1483225200);
        return sc.calculate(new Time.Moment(now.value() + day * Time.Gregorian.SECONDS_PER_DAY), lastLoc, what);
    }

}
