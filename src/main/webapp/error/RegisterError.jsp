<%@page contentType="text/html" pageEncoding="UTF-8"%>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>Register Error</title>
    <style>
        body {
            font-family: Arial, sans-serif; 
            color: #721c24;
            text-align: center;
            padding: 50px;
        }
        .error-box {
            border: 1px solid #f5c6cb;
            background-color: #f8d7da;
            padding: 20px;
            border-radius: 8px;
            display: inline-block;
            box-shadow: 0 2px 6px rgba(0,0,0,0.2);
        }
        h2 {
            margin-top: 0;
        }
        a {
            color: #004085;
            text-decoration: none;
            font-weight: bold;
        }
        a:hover {
            text-decoration: underline;
        }
    </style>
</head>
<body>
    <div class="error-box">
        <h2>Registration Failed</h2>
        <p>${errorMessage}</p>
        <p><a href="${pageContext.request.contextPath}/register.jsp">Try Again</a></p>
    </div>
</body>
</html>
