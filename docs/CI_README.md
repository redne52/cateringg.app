CI / CD for Firebase Hosting

Bu rehber, GitHub Actions ile Flutter Web uygulamanızı otomatik olarak derleyip Firebase Hosting'e dağıtmak için gereken adımları açıklar.

1) FIREBASE_TOKEN oluşturun (lokal makinede):

   - Önce Firebase CLI yüklü değilse yükleyin:
     npm install -g firebase-tools

   - Ardından token almak için:
     firebase login:ci

   - Komut tarayıcıda sizi oturum açmaya yönlendirir. İşlem tamamlandığında bir token verilir — bunu kopyalayın.

2) GitHub Secrets ekleyin:

   - GitHub → Repository → Settings → Secrets and variables → Actions → New repository secret
   - Name: FIREBASE_TOKEN
   - Value: (az önce kopyaladığınız token)

3) Dosyaları repoya ekleyin ve push edin:

   git add .github/workflows/firebase-hosting.yml firebase.json docs/CI_README.md
   git commit -m "Add CI workflow, firebase.json and CI guide"
   git push origin main

4) Kullanım:

   - Push yaptığınızda veya main'e PR merge edildiğinde workflow tetiklenir.
   - Workflow, `flutter build web` ile `build/web` klasörünü oluşturur ve `firebase deploy` ile Hosting'e gönderir.

Not: Ben `FIREBASE_TOKEN` ekleyemem; token'ı GitHub Secrets'a sizin eklemeniz gerekir.
