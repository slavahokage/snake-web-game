<%@ taglib prefix="spring" uri="http://www.springframework.org/tags" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@
        taglib
        prefix="security"
        uri="http://www.springframework.org/security/tags"
%>

<%@ taglib prefix="fmt" uri="http://java.sun.com/jsp/jstl/fmt" %>

<c:set var="contextPath" value="${pageContext.request.contextPath}"/>
<html>
<head>
    <title>My results</title>
    <link rel="stylesheet" href="https://bootswatch.com/4/cosmo/bootstrap.min.css">
    <link rel="stylesheet" href="${contextPath}/resources/css/for-image.css">
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

<div class="container">
        <blockquote class="blockquote text-center">
            <h3>Best results</h3>
        </blockquote>
    <table class="table table-hover">
        <thead>
        <tr>
            <th scope="col">N</th>
            <th scope="col">nickname</th>
            <th scope="col">score</th>
            <th scope="col">time</th>
        </tr>
        </thead>
        <tbody>
        <c:set var="count" value="0" scope="application"/>
        <c:forEach items="${bestResults}" var="b">
            <tr>
                <td>${count+1}</td>
                <td>${b.user.username}</td>
                <td>${b.score}</td>
                <td>${formatTime[count]}</td>
            </tr>

            <c:set var="count" value="${count=count+1}" scope="application"/>
        </c:forEach>
        </tbody>
    </table>
</div>
<script src="https://ajax.googleapis.com/ajax/libs/jquery/3.3.1/jquery.min.js"></script>
<script src="https://cdnjs.cloudflare.com/ajax/libs/popper.js/1.14.3/umd/popper.min.js"
        integrity="sha384-ZMP7rVo3mIykV+2+9J3UJ46jBk0WLaUAdn689aCwoqbBJiSnjAK/l8WvCWPIPm49"
        crossorigin="anonymous"></script>
<script src="https://stackpath.bootstrapcdn.com/bootstrap/4.1.3/js/bootstrap.min.js"
        integrity="sha384-ChfqqxuZUCnJSK3+MXmPNIyE6ZbWh2IMqE241rYiqJxyMiZ6OW/JmZQ5stwEULTy"
        crossorigin="anonymous"></script>
</body>
</html>
