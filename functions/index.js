/* eslint-disable max-len */
const functions = require("firebase-functions");
const admin = require("firebase-admin");
admin.initializeApp(functions.config().firebase);

exports.reservationNotification = functions.database
    .ref("reservations/current/{reservationId}/")
    .onUpdate((evt) => {
      const status = evt.after.val()["status"];
      const statusBefore = evt.before.val()["status"];
      const cancelR = evt.after.val()["cancelR"];

      if (status == statusBefore) {
        return;
      }

      if (status == "approved" || (status == "canceled" && cancelR == "true")) {
        const uid = evt.after.val()["userId"];
        const noOfPersons = evt.after.val()["noPersons"];
        let title;
        let body;
        if (status == "approved") {
          title = "Felicitări!";
          body = "Rezervarea dumneavoastră de " + noOfPersons.toString() + " persoane a fost aprobată.";
        } else if (status == "canceled") {
          title = "Ne pare rău!";
          body = "Rezervarea dumneavoastră nu a fost aprobată deoarece nu mai sunt locuri disponibile. Vă rugăm selectați alt interval orar.";
        }

        // Get a database reference to our posts
        const db = admin.database();
        let deviceOs="";
        let payload;

        const refDevice = db.ref("usersDetails/" + uid + "/device_os");
        refDevice.on("value", (snapshot) => {
          deviceOs = snapshot.val();
          if (deviceOs == "android") {
            payload = {
              data: {
                title: title,
                body: body,
                type: status == "approved" ? "reservationAccepted" : "reservationCanceled",
              },
            };
          } else if (deviceOs == "ios") {
            payload = {
              notification: {
                title: title,
                body: body,
                sound: "default",
              },
              data: {
                title: title,
                body: body,
                type: status == "approved" ? "reservationAccepted" : "reservationCanceled",
              },
            };
          }
          const ref = db.ref("usersDetails/" + uid + "/fcm_token");
          ref.on("value", (snapshot) => {
            const token = snapshot.val();
            return admin.messaging().sendToDevice(token, payload);
          }, (errorObject) => {
            console.log("The read failed for token: " + errorObject.name);
          });
        }, (errorObject) => {
          console.log("error " + deviceOs);
          console.log("The read failed for device os: " + errorObject.name);
        });
      } else {
        return;
      }
    });

exports.orderNotification = functions.database
    .ref("orders/current/{orderId}/")
    .onUpdate((evt) => {
      const status = evt.after.val()["status"];
      const orderType = evt.after.val()["orderType"];
      const statusBefore = evt.before.val()["status"];

      if (status == statusBefore) {
        return;
      }

      if (status == "sent" || status == "preparing" || status == "canceledR") {
        const uid = evt.after.val()["userId"];

        let title;
        let body;

        if (status == "sent") {
          if (orderType == "address") {
            title = "Comanda ta este pe drum!";
            body = "Curierul a preluat comanda și este în drum spre tine.";
          } else {
            title = "Comanda ta este pregătită!";
            body = "Vă așteptăm în restaurantul nostru pentru a ridica produsele.";
          }
        } else if (status == "preparing") {
          title = "Comanda ta a fost preluată!";
          body = "Bucătarii noștrii îți pregătesc mâncarea ta preferată.";
        } else {
          title = "Comanda ta a fost anulată!";
          body = "Atingeți pentru a vedea mai multe detalii.";
        }

        // Get a database reference to our posts
        const db = admin.database();
        let deviceOs;
        let payload;

        const refDevice = db.ref("usersDetails/" + uid + "/device_os");
        refDevice.on("value", (snapshot) => {
          deviceOs = snapshot.val();
          if (deviceOs == "android") {
            payload = {
              data: {
                title: title,
                body: body,
                type: "order",
              },
            };
          } else if (deviceOs == "ios") {
            payload = {
              notification: {
                title: title,
                body: body,
                sound: "default",
              },
              data: {
                title: title,
                body: body,
                type: "order",
              },
            };
          }

          const ref = db.ref("usersDetails/" + uid + "/fcm_token");
          ref.on("value", (snapshot) => {
            const token = snapshot.val();
            return admin.messaging().sendToDevice(token, payload);
          }, (errorObject) => {
            console.log("The read failed for token: " + errorObject.name);
          });
        }, (errorObject) => {
          console.log("error " + deviceOs);
          console.log("The read failed for device os: " + errorObject.name);
        });
      } else {
        return;
      }
    });

const stripe = require("stripe")("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");
exports.createNewCustomer = functions.https.onRequest( async (req, res)=>{
  stripe.customers.create({
    payment_method: req.query.paymentMethodId,
    email: req.query.email,
  },
  function(err, customer) {
    if (err!==null) {
      console.log(err);
      res.send("error");
    } else {
      res.send(customer.id);
    }
  });
});

exports.addPaymentMethod = functions.https.onRequest( async (req, res)=>{
  await stripe.paymentMethods.attach(
      req.query.paymentMethod,
      {customer: req.query.customerId,
      },
      function(err, customer) {
        if (err!==null) {
          res.send("error");
        } else {
          res.send("success");
        }
      });
});

exports.loadPaymentMethods = functions.https.onRequest( async (req, res)=>{
  await stripe.customers.listPaymentMethods(
      req.query.customerId,
      {type: "card"},
      function(err, paymentMethods) {
        if (err!==null) {
          console.log(err);
          res.send("error");
        } else {
          res.send(paymentMethods);
        }
      });
});

exports.createPaymentIntent = functions.https.onRequest(async (req, res) => {
  const customer = await stripe.customers.retrieve(req.query.customerId);

  if (customer["email"].includes("@fastapp.ro")) {
    // console.log("")
    stripe.paymentIntents.create({
      amount: req.query.amount,
      currency: req.query.currency,
      customer: req.query.customerId,
      payment_method_types: ["card"],
      // setup_future_usage: "on_session",
    },
    function(err, paymentIntent) {
      if (err!==null) {
        console.log(err);
        res.send("error");
      } else {
        res.send(paymentIntent);
      }
    },
    );
  } else {
    stripe.paymentIntents.create({
      amount: req.query.amount,
      currency: req.query.currency,
      customer: req.query.customerId,
      payment_method_types: ["card"],
      receipt_email: customer["email"],
      // setup_future_usage: "on_session",
    },
    function(err, paymentIntent) {
      if (err!==null) {
        console.log(err);
        res.send("error");
      } else {
        res.send(paymentIntent);
      }
    },
    );
  }
});

exports.returnCustomerEmail = functions.https.onRequest(async (req, res) => {
  const customer = await stripe.customers.retrieve(req.query.customerId);
  if (customer["email"].includes("@fastapp.ro")) {
    res.send("FASTAPP");
  } else {
    res.send(customer["email"]);
  }
});
