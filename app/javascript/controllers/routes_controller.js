import { Controller } from "@hotwired/stimulus"
import * as d3 from "d3";
import * as Plot from "@observablehq/plot";

export default class extends Controller {

    static values = {
        data: Array
    }

    connect() {
        console.log('Inside routes_controller.js');

        const trains = this.dataValue;

        function asTime(minutes) {
            return formatTime(d3.utcMinute.offset(d3.utcDay(), minutes - minutesOffset));
        }

        var minutesOffset = -60 * 2 // no trains run at 2 AM

        var parseTime = d3.utcParse("%I:%M%p")

        var formatTime = d3.utcFormat("%-I %p")

        var schedule = "weekday"

        function asMinutes(time) {
            if (!(time = parseTime(time))) return;
            const minutes = time.getUTCHours() * 60 + time.getUTCMinutes();
            return (minutes + minutesOffset + 60 * 24) % (24 * 60);
        }

        var plot = Plot.plot({
            inset: 10,
            margin: 10,
            marginLeft: 40,
            marginTop: 100,
            grid: true,
            width: 1152,
            height: 1800,
            x: {
                axis: null // hide arbitrary distance units
            },
            y: {
                label: null,
                ticks: d3.range(3, 24).map(h => h * 60),
                tickFormat: asTime,
                transform: asMinutes,
                reverse: true
            },
            color: {
                legend: true,
                domain: ["normal", "limited", "bullet"],
                range: ["rgb(34, 34, 34)", "rgb(183, 116, 9)", "rgb(192, 62, 29)"]
            },
            marks: [
                Plot.ruleX(trains, Plot.groupX({}, {x: "distance", strokeOpacity: 0.1, strokeDasharray: 2})),
                Plot.text(trains, Plot.groupX({text: "first", y: () => "4:30am"}, {x: "distance", text: "station", rotate: -90, frameAnchor: "left", dy: -12})),
                Plot.line(trains, {filter: d => d.schedule === schedule, x: "distance", y: "time", z: "train", stroke: "speed", marker: "circle", title: (d) => `${d.train}${d.direction}\n${d.station}\n${d.time}`, tip: true})
            ]
        });

        const div = document.querySelector("#myplot");
        div.append(plot);



    }
}