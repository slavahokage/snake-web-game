<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}"/>


<html>
<head>

    <link rel="stylesheet" href="https://bootswatch.com/4/cosmo/bootstrap.min.css">
    <link rel="stylesheet" href="${contextPath}/resources/css/game.css">

</head>
<body>
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container">
        <a class="navbar-brand" href="/game" style="color: white">Snake game</a>
        <div class="collapse navbar-collapse" id="mobile-nav">
            <ul class="navbar-nav mr-auto"></ul>
            <form class="form-inline my-2 my-lg-0">
                <div class="btn-group" role="group">
                    <button id="btnGroupDrop1" type="button" class="btn btn-primary dropdown-toggle inline"
                            data-toggle="dropdown" aria-haspopup="true" aria-expanded="false">
                        <span class="caret">${pageContext.request.userPrincipal.name}</span>
                        <div class="edititem inline">
                            <img src=${user.srcImage}>
                        </div>
                    </button>
                    <div class="dropdown-menu" aria-labelledby="btnGroupDrop1" x-placement="bottom-start"
                         style="position: absolute; will-change: transform; top: 0px; left: 0px; transform: translate3d(0px, 35px, 0px);">
                        <a class="dropdown-item" href="/myResults">My results</a>
                        <a class="dropdown-item" href="/bestResults">Best results</a>
                        <a class="dropdown-item" href="/editAccount">Edit account</a>
                        <div class="dropdown-divider"></div>
                        <a class="dropdown-item" href="/logout">Log out</a>
                        <a class="dropdown-item" href="/registration">Sign in</a>
                    </div>
                </div>
            </form>
        </div>
    </div>
</nav>


<blockquote class="blockquote text-center">
    <h3 id="score">Your score: 0</h3>
    <h3 id="time">Your time: 00:00:00</h3>
</blockquote>
<div>
    <canvas id="mc" width="1280" height="600"></canvas>
</div>
</body>
<script>
    window.onload = function () {
        document.addEventListener('keydown', changeDirection);
        setInterval(loop, 1000 / 60); // 60 FPS
    }

    var
        canv = document.getElementById('mc'), // canvas
        scoreText = document.getElementById("score"),
        timeText = document.getElementById('time'),
        timeStart = new Date(),
        timeEnd = {},
        time = {},
        ctx = canv.getContext('2d'), // 2d context
        gs = fkp = false, // game started && first key pressed (initialization states)
        speed = baseSpeed = 3, // snake movement speed
        xv = yv = 0, // velocity (x & y)
        px = ~~(canv.width) / 2, // player X position
        py = ~~(canv.height) / 2, // player Y position
        pw = ph = 20, // player size
        aw = ah = 20, // apple size
        apples = [], // apples list
        trail = [], // tail elements list (aka trail)
        tail = 100, // tail size (1 for 10)
        tailSafeZone = 20, // self eating protection for head zone (aka safeZone)
        cooldown = false, // is key in cooldown mode
        isStart = false,
        isStop = false,
        score = 0; // current score


    // game main loop
    function loop() {
        if (isStop === false) {
            // logic
            ctx.fillStyle = 'black';
            ctx.fillRect(0, 0, canv.width, canv.height);

            // force speed
            px += xv;
            py += yv;

            // teleports
            if (px > canv.width) {
                px = 0;
            }

            if (px + pw < 0) {
                px = canv.width;
            }

            if (py + ph < 0) {
                py = canv.height;
            }

            if (py > canv.height) {
                py = 0;
            }

            // paint the snake itself with the tail elements
            ctx.fillStyle = 'lime';
            for (var i = 0; i < trail.length; i++) {
                ctx.fillStyle = trail[i].color || 'lime';
                ctx.fillRect(trail[i].x, trail[i].y, pw, ph);
            }

            trail.push({x: px, y: py, color: ctx.fillStyle});

            // limiter
            if (trail.length > tail) {
                trail.shift();
            }

            // eaten
            if (trail.length > tail) {
                trail.shift();
            }

            // self collisions
            if (trail.length >= tail && gs) {
                for (var i = trail.length - tailSafeZone; i >= 0; i--) {
                    if (
                        px < (trail[i].x + pw)
                        && px + pw > trail[i].x
                        && py < (trail[i].y + ph)
                        && py + ph > trail[i].y
                    ) {
                        // got collision
                        tail = 10; // cut the tail
                        speed = baseSpeed; // cut the speed (flash nomore lol xD)

                        for (var t = 0; t < trail.length; t++) {
                            // highlight lossed area
                            trail[t].color = 'red';

                            if (t >= trail.length - tail) {
                                break;
                            }
                        }
                        timeEnd = new Date();
                        time = timeEnd - timeStart;
                        isStop = true;
                        canv.remove();
                        ajaxRequestWithResults();
                        addImage();
                        addButtons();
                        break;
                    }
                }
            }

            // paint apples
            for (var a = 0; a < apples.length; a++) {
                ctx.fillStyle = apples[a].color;
                ctx.fillRect(apples[a].x, apples[a].y, aw, ah);
            }

            // check for snake head collisions with apples
            for (var a = 0; a < apples.length; a++) {
                if (
                    px < (apples[a].x + pw)
                    && px + pw > apples[a].x
                    && py < (apples[a].y + ph)
                    && py + ph > apples[a].y
                ) {
                    // got collision with apple
                    apples.splice(a, 1); // remove this apple from the apples list
                    changeScore();

                    tail += 10; // add tail length
                    speed += .1; // add some speed
                    spawnApple(); // spawn another apple(-s)
                    break;
                }
            }

            if (isStart === true) {
                changeTime();
            }

        }
    }

    // apples spawner
    function spawnApple() {
        var
            newApple = {
                x: ~~(Math.random() * canv.width),
                y: ~~(Math.random() * canv.height),
                color: 'red'
            };

        // forbid to spawn near the edges
        if (
            (newApple.x < aw || newApple.x > canv.width - aw)
            ||
            (newApple.y < ah || newApple.y > canv.height - ah)
        ) {
            spawnApple();
            return;
        }

        // check for collisions with tail element, so no apple will be spawned in it
        for (var i = 0; i < tail.length; i++) {
            if (
                newApple.x < (trail[i].x + pw)
                && newApple.x + aw > trail[i].x
                && newApple.y < (trail[i].y + ph)
                && newApple.y + ah > trail[i].y
            ) {
                // got collision
                spawnApple();
                return;
            }
        }

        apples.push(newApple);

        if (apples.length < 3 && ~~(Math.random() * 1000) > 700) {
            // 30% chance to spawn one more apple
            spawnApple();
        }
    }

    // random color generator (for debugging purpose or just 4fun)
    function rc() {
        return '#' + ((~~(Math.random() * 255)).toString(16)) + ((~~(Math.random() * 255)).toString(16)) + ((~~(Math.random() * 255)).toString(16));
    }

    // velocity changer (controls)
    function changeDirection(evt) {
        if (!fkp && [37, 38, 39, 40].indexOf(evt.keyCode) > -1) {
            timeStart = new Date();
            isStart = true;
            setTimeout(function () {
                gs = true;
            }, 1000);
            fkp = true;
            spawnApple();
        }

        if (cooldown) {
            return false;
        }

        /*
          4 directional movement.
         */
        if (evt.keyCode == 37 && !(xv > 0)) // left arrow
        {
            xv = -speed;
            yv = 0;
        }

        if (evt.keyCode == 38 && !(yv > 0)) // top arrow
        {
            xv = 0;
            yv = -speed;
        }

        if (evt.keyCode == 39 && !(xv < 0)) // right arrow
        {
            xv = speed;
            yv = 0;
        }

        if (evt.keyCode == 40 && !(yv < 0)) // down arrow
        {
            xv = 0;
            yv = speed;
        }

        cooldown = true;
        setTimeout(function () {
            cooldown = false;
        }, 100);
    }

    function changeTime() {
        let difference = (new Date() - timeStart)/1000;
        const sec_num = parseInt(difference, 10); // don't forget the second param
        let hours = Math.floor(sec_num / 3600);
        let minutes = Math.floor((sec_num - (hours * 3600)) / 60);
        let seconds = sec_num - (hours * 3600) - (minutes * 60);

        if (hours < 10) {
            hours = "0" + hours;
        }
        if (minutes < 10) {
            minutes = "0" + minutes;
        }
        if (seconds < 10) {
            seconds = "0" + seconds;
        }

        timeText.innerHTML = 'You time: ' + hours + ":" + minutes + ":" + seconds;
    }

    function changeScore() {
        score++;
        scoreText.innerHTML = 'You score: '+score;
    }

   function ajaxRequestWithResults() {
        $.ajax({
            url: "/results",
            type: 'POST',
            data: {
                "score": score,
                 "time": time
            },
            success: function (result) {
                console.log(result)
            }
        });
    }


    function addButtons() {
        let newDiv = document.createElement("div");
        newDiv.setAttribute("id", "buttons");
        newDiv.innerHTML = "" +
            "<blockquote class=\"blockquote text-center\">" +
            "<a type='button' class='btn btn-primary btn-lg active' href='${contextPath}/game' id = 'again' role=\"button\" aria-pressed=\"true\">Play again</a>" +
            "<a type='button' class='btn btn-primary btn-lg active' href='${contextPath}/myResults' id = 'again' role=\"button\" aria-pressed=\"true\">My results</a>" +
            "<a type='button' class='btn btn-primary btn-lg active' href='${contextPath}/bestResults' id = 'again' role=\"button\" aria-pressed=\"true\">Best results</a>" +
            "</blockquote>";
        document.body.appendChild(newDiv);
    }

    function addImage() {
        let newDiv = document.createElement("div");
        newDiv.setAttribute("id", "image");
        newDiv.innerHTML = "" +
            "<blockquote class=\"blockquote text-center\">" +
            "     <img id = 'snakeImg' src=\"${contextPath}/resources/image/snake_default_logo.png\">" +
            "</blockquote>";
        document.body.appendChild(newDiv);
    }

</script>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"
        integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49"
        crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"
        integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy"
        crossorigin="anonymous"></script>

</html>