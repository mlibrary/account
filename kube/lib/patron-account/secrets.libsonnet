local arr = std.parseJson(importstr './secrets.json');
{
  _functions::{
    secret(name, key): {
      name: key,
      valueFrom: {
        secretKeyRef: {
          key: key,
          name: name,
        },
      }
    },
  },
  _secrets::[
     $._functions.secret(x.name, x.key),
   for x in arr 
  ],
}
