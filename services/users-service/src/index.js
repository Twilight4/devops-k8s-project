const express = require('express');
const app = express();
app.use(express.json());
app.get('/health', (req,res)=>res.send('ok'));
app.get('/users', (req,res)=>res.json([{id:1,name:"Alice"}]));
app.listen(process.env.PORT || 3001, ()=>console.log('users running'));
