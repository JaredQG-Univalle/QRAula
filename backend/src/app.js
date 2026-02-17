const express = require("express");
const cors = require("cors");
const morgan = require("morgan");

const routes = require("./routes");

const notFound = require("./middlewares/notfound.middleware");
const errorHandler = require("./middlewares/error.middleware");

const app = express();

app.use(cors());
app.use(express.json());
app.use(morgan("dev"));

app.get("/", (req, res) => {
  res.send("🚀 Backend activo correctamente (MVC)");
});

app.use("/", routes);

app.use(notFound);

app.use(errorHandler);

module.exports = app;
