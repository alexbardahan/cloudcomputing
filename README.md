Aplicatie mobila Cafe Noir
Bardahan Alexandru-Mihai
Grupa 1119

Link Video prezentare proiect:

Link publicare:
Android: https://play.google.com/store/apps/details?id=ro.fastapp.cafe_noir
iOS: https://apps.apple.com/us/app/cafe-noir/id1592372469

1. Introducere
Aplicatia Cafe Noir a fost facuta de mine personal pentru parintii mei care detin un restaurant in Orasul Braila numit "Cafe Noir" si este folosita si in prezent intr-un mod real pentru comenzi.

Cafe Noir este o aplicație mobilă dezvoltată cross-platform, pentru Android și iOS, ce are ca scop creșterea vânzărilor restaurantului în ceea ce privește livrările la domiciliu, dar și îmbunătățirea experienței utilizatorilor prin oferirea unor funcționalități noi, moderne. Aplicația are ca rol principal fidelizarea clientului și transformarea acestuia într-un client recurent, care comanda în fiecare zi. Alte beneficii sunt creșterea vizibilității brand-ului și diferențierea față de concurență. Astfel, utilizatorii, reprezentați de clienții restaurantului, vor putea beneficia de funcționalități precum crearea unui cont de client și autentificarea în aplicație, vizualizarea produselor restaurantului, adăugarea produselor în coș, efectuarea unei comenzi la domiciliu sau ridicarea personală a produselor din restaurant, alegerea dintre plata cash sau cu cardul prin aplicație, efectuarea de rezervări direct din aplicație pentru data și ora selectate, vizualizarea ofertelor și promoțiilor susținute de restaurant. Beneficiile utilizării acestei aplicații includ fidelizarea crescută a clienților, posibilitatea de a comanda preparatele dorite într-un timp scurt, eliminarea erorilor umane prezente în cadrul comenzilor telefonice, posibilitatea de a da notificări push clienților, creșterea vizibilității și a notorietății brand-ului, centralizarea comenzilor și simplificarea procedeelor interne, colectarea datelor în scopul determinării tendințelor clienților și adaptarea meniului în funcție de acestea.

2. Descriere problema

Cafe Noir vine în întâmpinarea nevoilor utilizatorilor resturantului nostru prin numeroase beneficii si avantaje. Aceasta are ca scop creșterea vânzărilor restaurantului prin livrarea la domiciliu și îmbunătățirea experienței utilizatorilor prin oferirea unor funcționalități noi și moderne. 

Pentru utilizatori, Cafe Noir oferă o experiență de comandă simplă și rapidă, cu posibilitatea de a vizualiza meniul restaurantului, împreună cu descriere, poze și videoclipuri de prezentare. Utilizatorii pot adăuga produse în coș, selectând cantitatea și instrucțiunile speciale, dacă există, și pot efectua o comandă la domiciliu prin selectarea adresei de livrare. De asemenea, utilizatorii pot alege să ridice personal produsele din restaurant la ora selectată și pot efectua rezervări direct din aplicație pentru data și ora selectate. 

Pentru restaurant, Cafe Noir oferă o interfață specializată, ce rulează pe o tabletă SunMi cu imprimantă termică, prin care acestea pot vedea comenzile și rezervările efectuate. Fiecare comandă care intră notifică operatorul printr-un semnal sonor, iar acesta are posibilitatea de a accepta sau refuza comenzile și rezervările. Odată acceptată comanda, clientul va fi notificat în legătură cu acest lucru, iar restaurantul poate da un timp estimat de livrare, ce îi va apărea clientului în aplicație. 

Cafe Noir vine în întâmpinarea nevoilor utilizatorilor și restaurantului prin oferirea unei soluții complete de livrare la domiciliu și gestionare a comenzilor. Utilizatorii beneficiază de o experiență de comandă simplă și rapidă, iar restaurantul poate gestiona comenzile și rezervările într-un mod eficient și organizat. De asemenea, Cafe Noir contribuie la creșterea vizibilității brand-ului și diferențierea față de concurență, prin oferirea de oferte și promoții susținute de restaurant. 

3. Descriere API

Integrarea cu Firebase în aplicația Cafe Noir a fost realizată prin utilizarea Firebase Realtime Database și Firebase Authentication. Firebase Realtime Database a fost folosit pentru stocarea datelor într-un fișier JSON complex și pentru sincronizarea acestora în timp real cu fiecare client. Pentru a asigura securitatea datelor, au fost folosite Firebase Realtime Database Rules, o suită de reguli specificate de dezvoltator pentru evitarea abuzurilor și acordarea permisiunilor corecte fiecărui tip de utilizator. Firebase Authentication a fost folosit pentru ușurarea procesului de autentificare prin diferite metode, simplificând și îmbunătățind experiența utilizatorului. Logarea a fost 100% securizată și include variante precum cea email și parola, număr de telefon, dar și integrarea unor terți precum Google, Apple, Facebook în procesul de autentificare.

Pentru a realiza autentificarea cu Google în aplicația Cafe Noir, s-a folosit pachetul "GoogleSignIn" care a permis crearea unui obiect utilizator și obținerea credențialelor. Acestea au fost ulterior folosite pentru a autentifica utilizatorul în Firebase Auth. Procesul de autentificare cu Google este similar cu celelalte variante de autentificare, iar utilizatorul este redirecționat către aplicația specifică de unde poate finaliza logarea.

4. Flux de date

Exemplu de request/Metoda HTTP:

 final url = Uri.parse(
        'https://cafenoir-737f5-default-rtdb.europe-west1.firebasedatabase.app/$databaseOrders/current.json?auth=$idToken');
    final timestamp = DateTime.now();

    // uniform string representation of dates, which we can later convert back to a date,
    await http.post(
      url,
      body: json.encode({
        'dateTime': timestamp.toIso8601String(),
        'cartItems': cart.items
            .map((cartItem) => {
                  'productId': cartItem.productInfo.id,
                  'quantity': cartItem.quantity,
                  'specialInstructions': cartItem.specialInstructions
                })
            .toList(),
        'address': address,
        'phoneNumber': phoneNumber,
        'payment': payment,
        'userId': userId,
        'orderType': orderType,
        'chosenTime': chosenTime,
        'tableNumber': tableNumber,
        'status': status,
        'discount': discount,
        'name': user.displayName,
        // 'deliveryCost': deliveryCost,
        'amount': amount,
      }),
    );

Autentificare:

  Future<void> signInWithGoogle() async {
    try {
      GoogleSignIn _googleSignIn = GoogleSignIn();
      final GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      if (googleUser != null) {
        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;
        final GoogleAuthCredential credential = GoogleAuthProvider.credential(
          idToken: googleAuth.idToken,
          accessToken: googleAuth.accessToken,
        );
        user = (await _firebaseAuth.signInWithCredential(credential)).user;
        _idToken = await user.getIdToken();
      }
    } catch (error) {
      print(error);
      throw error;
    }
  }

5. Capturile de ecran
![poza_1](http://deveatery.com/cafe-noir-cloud/1_photo.png)

6. Referinte

[1] „Online Food Delivery – Timeline” https://www.verdictfoodservice.com/comment/online-food-delivery-timeline/
[2] „History of food delivery and how its changed” https://www.thistle.co/learn/thistle-thoughts/history-of-food-delivery-and-how-its-changed
[3] „Online Food Ordering System For Restaurants” https://www.gloriafood.com/online-food-ordering-system-for-restaurants
[4] „Add Firebase to your Flutter app” https://firebase.google.com/docs/flutter/setup?platform=android
[5] „Flutter documentation” https://docs.flutter.dev
[6] „A Complete Guide on Restaurant App Development: All You Need to Know” https://www.fatbit.com/fab/restaurant-app-development/
[7] „Online payments” https://stripe.com/docs/payments/online-payments
[8] „Create Your App With Flutter In 5 Days
” https://levelup.gitconnected.com/create-your-app-with-flutter-in-5-days-412ee41de22a
[9] „How to Use the Provider Pattern in Flutter
” https://www.freecodecamp.org/news/provider-pattern-in-flutter/
