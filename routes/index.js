var path = require('path');
var express = require('express');
var router = express.Router();


router.get('/', function (req, res, next) {
    res.json({
        service: process.env.SERVICE_NAME,
        environment: process.env.ENVIRONMENT_NAME,
        pod: process.env.POD_NAME,
        image: process.env.IMAGE_TAG,
        message: "Application Version 1."
    })
});

module.exports = router;