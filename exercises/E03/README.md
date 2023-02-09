**Systém DHCP**

Zajištění konektivity mezi počítači v malé (např. domácí) síti je celkem
jednoduché, stačí manuálně nastavit jednotlivá síťová rozhraní. Často to
není ani nutné, jelikož lze využít automatické přidělování IPv4 adres
pomocí systému **APIPA**. Pokud ovšem pracujeme ve větší síti, což je v
případě existence serverů pravděpodobné, nejsou předchozí možnosti
příliš použitelné. Manuální konfigurace je pracná a náchylná na chyby
způsobené uživatelem (chybně zadané údaje apod.). Použití systému
**APIPA** je nepřijatelné, jelikož pravděpodobnost, že se podaří každému
počítači vygenerovat do deseti pokusů unikátní IPv4 adresu je v tomto
počtu mizivá.

**Systém DHCP** slouží k automatické konfiguraci síťových rozhraní.
Umožňuje nastavit IPv4 adresy, masky podsítě, výchozí brány, adresy
**DNS** a **WINS** serverů a další informace. Konfigurace jednotlivých
rozhraní je realizována pomocí protokolu **DHCP** (*Dynamic Host
Configuration Protocol*), který vzniknul jako rozšíření protokolu
**BOOTP**, jenž sloužil pro *bootování* bezdiskových stanic. **BOOTP**
byl schopen přidělovat jen IPv4 adresu, masku podsítě, adresu **TFTP**
(*Trivial File Transfer Protokol*) serveru, který obsahoval *bootovací*
obraz, a cestu k tomuto obrazu. Protože **DHCP** je rozšíření protokolu
**BOOTP**, je s ním také zpětně kompatibilní.

**Služba DHCP**

Stejně jako v případě **DNS** lze i zde **službu** **DHCP** rozdělit na
dvě části. První část tvoří **DHCP** server, jenž obsahuje informace o
IPv4 adresách přidělených jednotlivým rozhraním. Druhou částí je
**DHCP** klient, který zjišťuje informace potřebné pro konfiguraci
jednotlivých síťových rozhraní.

Jak již bylo řečeno výše, pro komunikaci se využívá **DHCP** protokol,
jenž běží na protokolem **UDP** na portech **67** (server) a **68**
(klient). Komunikace je vždy realizována pomocí všesměrového vysílání
(*broadcast*), jelikož ten jediný lze použít i v případě, že rozhraní
ještě nemá přidělenou IP adresu.

**Přidělování IPv4 adres pomocí DHCP**

Princip přidělování IPv4 adres je znázorněn na obrázku 4 níže. Postup
lze shrnout do následujících několika kroků:

1.  **DHCP** klient zašle všesměrovou (*broadcast*) zprávu **DHCP
    > Discover** všem **DHCP** serverům na dané síti, touto zprávou žádá
    > o přidělení IPv4 adresy.

2.  Každý **DHCP** server zašle zpět všesměrovou (*broadcast*) zprávu
    > **DHCP Offer**, která obsahuje IPv4 adresu, jenž server nabízí k
    > použití. V případě, že **DHCP** server nemá již k dispozici žádné
    > volné IPv4 adresy pro zapůjčení, nijak na žádosti nereaguje.

3.  **DHCP** klient čeká na nabídky od **DHCP** serverů. Z přijatých
    > nabídek vybere jedinou (nejčastěji první příchozí) a odpoví na ni
    > opět všesměrovou (*broadcast*) zprávou **DHCP Request**, kterou
    > stvrzuje svůj zájem o použití nabízené IPv4 adresy.

4.  **DHCP** server, jenž nabídl danou IPv4 adresu, ověří, zda je možné
    > tuto IPv4 adresu opravdu zapůjčit a v případě, že ano, zašle zpět
    > všesměrovou (*broadcast*) zprávou **DHCP Ack**, kterou potvrzuje
    > zapůjčení této IPv4 adresy. Pokud IPv4 adresu již z nějakého
    > důvodu nelze zapůjčit (např. již zatím byla zapůjčena jinému
    > rozhraní), odpoví všesměrovou (*broadcast*) zprávou **DHCP Nack**
    > a **DHCP** klient musí zažádat o novou (jinou) IPv4 adresu.

![dora.png](./img/media/image1.png){width="3.7505238407699037in"
height="3.938050087489064in"}

Obrázek 1. Průběh přidělování IPv4 adres pomocí DHCP (DORA)

Tento postup je často označován jako **DORA** (*Discover*, *Offer*,
*Request*, *Ack*) a popisuje přidělování IPv4 adres klientům, jenž ještě
nemají přidělenou žádnou IPv4 adresu. Adresa je vždy zapůjčována jen na
určitou dobu, kterou určuje **DHCP** server. **DHCP** klient pak musí
pravidelně tuto dobu prodlužovat zasíláním žádostí o prodloužení
výpůjčky (*lease renewal*).

Po vypršení 50% doby platnosti výpůjčky IPv4 adresy se začne **DHCP**
klient pokoušet prodloužit dobu její platnosti. Prodloužení je
realizováno zasláním normální (*unicast*) zprávy **DHCP Request**
**DHCP** serveru, jenž zapůjčil danou IPv4 adresu. Ten buď potvrdí
prodloužení výpůjčky pomocí zprávy **DHCP Ack** nebo zamítne pomocí
**DHCP Nack**. Pokud je prodloužení zamítnuto, klient si ponechá IPv4
adresu do konce doby její platnosti a pak si zažádá o novou. V případě,
že se **DHCP** klientovi nepodaří prodloužit výpůjčku do 87,5% doby její
platnosti, pokusí se klient kontaktovat jakýkoliv **DHCP** server, který
ji může prodloužit. Prodloužení se provede jako v předchozím případě,
jen **DHCP Request** je zaslán všesměrově (*broadcast*) všem serverům.
Pokud se **DHCP** klientovi vůbec nepodaří prodloužit výpůjčku do
vypršení její doby platnosti, znovu zažádá po vypršení o novou IPv4
adresu.

**DHCP relay**

Hlavní nevýhodou **DHCP** je jeho závislost na všesměrovém vysílání
(*broadcast*), **DHCP** zprávy tedy nelze standardně šířit za hranice
směrovačů do jiných (pod)sítí. **DHCP relay** slouží k přeposílání
**DHCP** zpráv do jiných sítí, přesněji k směrování **DHCP** zpráv z
dané (pod)sítě na **DHCP** server v jiné (pod)síti a naopak. Funkce DHCP
relay je ilustrována na obrázku 5 níže.

![dhcp_relay.png](./img/media/image2.png){width="7.0739041994750655in"
height="4.042230971128609in"}

Obrázek 2. Ilustrace funkce DHCP relay

Z obrázku 5 výše je vidět, že klienti z jiné (pod)sítě, jenž jsou
spojeni se směrovačem (*router*), který má podporu **DHCP relay**, jsou
schopni získat IPv4 adresu od **DHCP** serveru, zatímco jiní klienti za
směrovačem bez podpory **DHCP relay** ne, jelikož jejich požadavky se
nedostanou k **DHCP** serveru.

**Společné úkoly**

-   Pro přístup na server **file** (a jiné) přes síťové rozhraní
    *Default switch* je nutné použít jeho plně kvalifikované doménové
    jméno **file.nepal.local**

-   Přístupové údaje na server **file**: **nepal\\hstudent** heslo:
    **aaa**

-   Rozsah IP adres přidělených z *Default switch* se může od níže
    uvedeného rozsahu lišit.

-   Nepřipojené síťové daptéry je doporučeno zakázat uvnitř VM.

**Lab LS00 -- konfigurace virtuálních stanic**

Připojte sítové adaptéry stanic k následujícím virtuálním přepínačům:

| **Adaptér (MAC suffix)** | **LAN1 (-01)** | **LAN2 (-02)** | **LAN3 (-03)** | **LAN4 (-04)** |
|------------------|--------------|--------------|--------------|--------------|
| **w10-base**             | Nepřipojeno    | Private1       | Nepřipojeno    | Nepřipojeno    |
| **w2016-base**           | Nepřipojeno    | Private1       | Nepřipojeno    | Nepřipojeno    |

-   v případech, kdy je potřeba přistupovat na externí síť, připojte
    adaptér **LAN1** k přepínači *Default switch*.

**\
**

**Lektorské úkoly**

**Lab L01 -- Instalace a základní nastavení DHCP serveru**

> **Cíl cvičení**
>
> Povýšit server do role **DHCP** serveru a nastavit nový rozsah
> (*scope*) pro přidělování IPv4 adres, ověřit funkčnost připojením
> klienta do sítě
>
> **Potřebné virtuální stroje**
>
> **w10-base**
>
> **w2016-base**

Přihlaste se k **w2016-base** jako uživatel **administrator** s heslem
**aaa**

Na **w2016-base** nastavte statickou IPv4 adresu **192.168.1.1**

Otevřete okno **Network Connections** (Settings -- Network & Internet --
Ethernet -- Change adapter options), zvolte LAN2 a pak Properties

Zvolené síťové rozhraní musí odpovídat *Private1*, standardně to je LAN2

Vyberte Internet Protocol Version 4 (TCP/IPv4) a zvolte Properties

Zvolte Use the following IP address a jako IP address zadejte
**192.168.1.1**

Klikněte do zadávacího pole u Subnet mask, maska podsítě
**255.255.255.0** bude doplněna automaticky

Potvrďte OK

Spusťte **Server Manager**

Start → **Server Manager**

Doporučení: automaticky spuštěný server manager nejdříve zavřít (jinak
si průvodce přidáním DHCP může stěžovat na chybějící statickou IP)

Nainstalujte roli **DHCP** server

Vyberte Add Roles and Features z nabídky Manage

Pokračujte Next \>

Vyberte Role-based or feature-based installation a pokračujte Next \>

Vyberte aktuální server a pokračujte Next \>

V seznamu rolí vyberte DHCP Server, potvrďte přidání potřebných funkcí
Add Features a pokračujte třikrát Next \>

Potvrďte instalaci Install

Trvá cca 3 minuty (restart není potřeba)

Po dokončení instalace najdete v notifikacích Server Manageru odkaz na
Post-deployment Configuration DHCP serveru (Complete DHCP configuration)

V poinstalační průvodci potvrďte bezpečnostní skupiny pomocí Commit a
následně Close

Nakonfigurujte **DHCP server** - vytvořte nový rozsah **192.168.1.10 --
192.168.1.100** pro přidělování IPv4 adres klientům (rozhraním)

Spusťte DHCP Manager

Poznámka: od 2012 již není průvodce konfigurací při instalaci role

Buď z nabídky Tools -- DHCP nebo vyberte v levém sloupci roli DHCP a
z kontextové nabídky nad jménem serveru zvolte DHCP Manager

V DHCP konzoli zvolte Add/Remove Bindings... z nabídky nad
**w2016-base**

Zmiňte, že toto nastavení slouží k navázání **DHCP** serveru na
konkrétní rozhraní, na kterém bude naslouchat na příchozí **DHCP**
zprávy (následně okno zavřete)

V DHCP konzoli rozbalte uzel **w2016-base -- IPv4**

Z kontextové nabídky nad **IPv4** zvolte New scope

U Scope name zvolte název **Private1**, pokračujte Next \>

Start IP address nastavte na **192.168.1.10** a End IP address na
**192.168.1.100**

Zkontrolujte, že automaticky vyplněné pole Subnet mask obsahuje správnou
masku podsítě **255.255.255.0**, pokračujte Next \>

Zmiňte, k čemu slouží Exclusions a pokračujte Next \>

Nastavte Lease Duration na **8 hodin** (zmiňte, k čemu slouží, kdy je
dobré nastavit kratší interval apod.), pokračujte Next \>

V nastavení Configure DHCP Options vysvětlete, k čemu slouží, zvolte
Yes,... a Next \>

Default Gateway nenastavujte, Next \>

Nastavuje se později ve studentském úkolu.

V nastavení Domain Name and DNS Servers zadejte jako Parent Domain
doménu **testing2.local** a do DNS server IP address adresu
**192.168.1.1** a pokračujte Next \>

Tyto informace jsou zaslány spolu s IPv4 adresou **DHCP** klientovi a
slouží k nastavení **DNS** serverů a **DNS** *suffixů* pro dané síťové
rozhraní, **DNS** server bude nainstalován později v rámci jiného úkolu

Proběhne validace (ověření konektivity na DNS server) a upozornění, že
na zadané IP není DNS server, přesto jej přidáme Yes

V části WINS Servers nic nenastavujte a pokračujte Next \>

Zvolte Yes, I want to activate this scope now pro aktivaci vytvořeného
rozsahu a pokračujte Next \> a Finish

Zmiňte, že rozsah (*scope*) je potřeba aktivovat, aby začal poskytovat
IPv4 adresy

Přihlaste se k **w10-base** jako uživatel **student** s heslem **aaa**

Na **w10-base** vynuťte obnovení IPv4 adresy

Spusťte příkaz **ipconfig /renew**

Ověřte, že **w10-base** obdržel od **DHCP** serveru IPv4 adresu z
nastaveného rozsahu

**Lab L02 -- Pokročilé nastavení DHCP serveru**

> **Cíl cvičení**
>
> Seznámit se s pokročilýminastaveními DHCP serveru.
>
> **Potřebné virtuální stroje**
>
> **w2016-base**
>
> **Další prerekvizity**
>
> Dokončený úkol **Lab L01**

Otevřete **DHCP** konzoli (buď samostatně, nebo v rámci **Server
Manageru**) a projděte pokročilejší možnosti nastavení **DHCP** serveru.
Ukažte, že informace, jenž jsou obsažené v **DHCP** zprávách spolu
s přidělenou IPv4 adresou, lze nastavovat na úrovních *serveru*,
*rozsahu* nebo jednotlivých *rezervací*. Vysvětlete, k čemu jsou dobré
rezervace. Zmiňte, že ve Windows Server lze vytvářet super rozsahy
(*superscopes*) a k čemu jsou. Také řekněte, proč jsou potřeba *exclude*
rozsahy a ukažte, kde se dají nastavit. Nakonec proberte filtry, které
lze využít pro výběr klientů, kterým bude daný DHCP server poskytovat
své služby, mají na to pak bodovaný úkol.

**Studentské úkoly**

**Lab S01 -- Vytvoření rezervace pro DHCP klienta**

> **Cíl cvičení**
>
> Na **DHCP** serveru vytvořit rezervaci pro klienta a ověřit, v jakém
> pořadí se aplikují nastavení obsažená v **DHCP** zprávách, pokud jsou
> definována na různých úrovních
>
> **Potřebné virtuální stroje**
>
> **w10-base**
>
> **w2016-base**
>
> **Další prerekvizity**
>
> Dokončený úkol **Lab L01**

1.  Na **w2016-base** nastavte na úrovni *serveru* a *rozsahu*
    **Private1** různé výchozí brány

    a.  Spusťte **DHCP**

    b.  V DHCP konzoli rozbalte uzel **w2016-base -- IPv4**

    c.  Klikněte pravým na Server Options a zvolte Configure Options...

    d.  V záložce General zaškrtněte možnost 003 Router

    e.  Do IP address zadejte **192.168.1.1** a zvolte Add

    f.  Potvrďte OK

    g.  Rozbalte uzel rozsahu **Private1**

    h.  Zopakujte body **c** - **f** tentokrát pro Scope Options a
        adresu **192.168.1.2**

2.  Na **w10-base** obnovte přidělenou IPv4 adresu pomocí příkazu
    **ipconfig /renew**

    -   Obnovení IPv4 adresy zároveň obnoví veškerá nastavení, jenž při
        přidělování poskytuje **DHCP** server klientům

3.  Ověřte, že **w10-base** má nastavenou jako výchozí bránu IPv4 adresu
    **192.168.1.2**

    -   Nastavení na úrovni *rozsahu* mají vždy přednost před
        nastaveními na úrovni *serveru*

4.  Vytvořte pro **w10-base** rezervaci u **DHCP** serveru

    a.  Na **w10-base** zjistěte pomocí příkazu **ipconfig /all**
        fyzickou (MAC) adresu rozhraní LAN2

        -   Síťové rozhraní musí odpovídat *Private1*, standardně to je
            LAN2

        -   (00-10-01-00-00-02)

    b.  Na **w2016-base** otevřete **DHCP**

    c.  Klikněte pravým na Reservations a zvolte New Reservation...

    d.  Rezervaci pojmenujte **w10-base** (pole Reservation Name)

    e.  Jako IP address zvolte **192.168.1.50** a do MAC address zadejte
        zjištěnou fyzickou adresu

        -   Cílová IP adresa musí být samozřejmě vždy z rozsahu
            poskytovaných IPv4 adres

        -   Fyzickou (MAC) adresu lze zadat s i bez pomlček, interně se
            ukládá bez

    f.  Přidejte rezervaci pomocí Add

    g.  Zavřete okno New Reservation pomocí Close

5.  Nastavte výchozí bránu **192.168.1.3** pro rezervaci **w10-base**

    a.  Klikněte pravým na rezervaci **w10-base** a zvolte Configure
        Options...

    b.  V záložce General zaškrtněte možnost 003 Router

    c.  Do IP address zadejte **192.168.1.3** a zvolte Add

    d.  Potvrďte OK

6.  Na **w10-base** opět obnovte přidělenou IPv4 adresu pomocí příkazu
    **ipconfig /renew**

7.  Ověřte, že **w10-base** má přidělenou IPv4 adresu **192.168.1.50** a
    nastavenou výchozí bránu **192.168.1.3**

    -   IP adresa, jenž je zarezervována pro určitého klienta, nemůže
        být nikdy přidělena jinému klientovi

    -   Nastavení na úrovni jednotlivých rezervací mají vždy přednost
        před stejnými nastaveními na ostatních úrovních

**Lab S02 -- Aplikace nastavení DHCP na základě user class**

> **Cíl cvičení**
>
> Přidat rozhraní do vytvořené *user class* a ověřit aplikaci nastavení
> pouze na její členy
>
> **Potřebné virtuální stroje**
>
> **w10-base**
>
> **w2016-base**
>
> **Další prerekvizity**
>
> Dokončeny úkol **Lab S01**

Na **w2016-base** vytvořte novou *user* *class* s názvem **ugtest**

Spusťte **DHCP**

Klikněte pravým na IPv4 a zvolte Define User Classes...

Zvolte Add

Do Display Name a části ASCII zadejte **ugtest** (Binary část bude
automaticky doplněna)

Potvrďte vytvoření pomocí OK

Zavřete okno DHC User Classes

Nastavte adresu **192.168.1.4** jako výchozí bránu pro klienta s *user
class* **ugtest**

V **DHCP** klikněte pravým na rezervaci **w10-base** a zvolte Configure
Options...

V záložce Advanced zvolte u User class **ugtest** a zaškrtněte možnost
003 Router

Do IP address zadejte **192.168.1.4** a zvolte Add

Potvrďte OK

Přidejte síťové rozhraní LAN2 na **w10-base** do *user class* **ugtest**

Síťové rozhraní musí odpovídat *Private1*, standardně to je LAN2

a.  Na **w10-base** spusťte v příkazovém řádku s administrátosrkými
    oprávněními příkaz **ipconfig /setclassid \"LAN2\" ugtest**

    -   Nastavení *user class* pro dané rozhraní vyžaduje
        administrátorské oprávnění

```{=html}
<!-- -->
```
3.  Ověřte, že **w10-base** má nastavenou jako výchozí bránu IPv4 adresu
    **192.168.1.4**

    -   Nastavení pro konkrétní *user class* má vždy přednost před
        nastavením pro všechny**\
        **

