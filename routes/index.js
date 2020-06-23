var path = require('path');
var express = require('express');
var router = express.Router();


router.get('/admin', function (req, res, next) {
    re.json({app: "healthy"})
});

module.exports = router;