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
    var app;

    function initialize() {
        WatchFace.initialize();
        DAY_IN_ADVANCE = 0;
        sc = new SunCalc();
        lastLoc = null;
        app = Application.getApp();
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
        lastLoc = Activity.getActivityInfo().currentLocation;
        var coordString = "yo";
        if (lastLoc != null) {
          // persistent storage; currentLocation is not stored forever
          // app.setProperty("lastLoc", lastLoc); // doesnt work?? variable type?
          var now = Time.now();
          var sunrise = Time.Gregorian.info(getMoment(SUNRISE), Time.FORMAT_SHORT);
          var sunset = Time.Gregorian.info(getMoment(SUNSET), Time.FORMAT_SHORT);
          coordString = Lang.format("$1$:$2$", [sunrise.hour.format("%02d"), sunrise.min.format("%02d")]);
          }

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
        return sc.calculate(new Time.Moment(now.value() + day * Time.Gregorian.SECONDS_PER_DAY), lastLoc.toRadians(), what);
    }

}
