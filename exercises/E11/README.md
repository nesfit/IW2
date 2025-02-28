- [Údržba Active Directory](#údržba-active-directory)
  - [Údržba databáze Active Directory](#údržba-databáze-active-directory)
  - [Ochrana Active Directory](#ochrana-active-directory)
  - [Záloha a obnova databáze Active Directory](#záloha-a-obnova-databáze-active-directory)
  - [Záloha databáze Active Directory](#záloha-databáze-active-directory)
  - [Záloha stavu systému](#záloha-stavu-systému)
  - [Obnova databáze Active Directory](#obnova-databáze-active-directory)
  - [Ochrana řadičů domény virtualizací](#ochrana-řadičů-domény-virtualizací)
  - [Active Directory koš](#active-directory-koš)
- [AutomatedLab](#automatedlab)
- [Společné úkoly](#společné-úkoly)
  - [Lab LS00 -- konfigurace virtuálních stanic](#lab-ls00----konfigurace-virtuálních-stanic)
- [Lektorské úkoly](#lektorské-úkoly)
  - [Lab L01 -- Ochrana Active Directory](#lab-l01----ochrana-active-directory)
  - [Lab L02 -- Záloha a obnova databáze Active Directory](#lab-l02----záloha-a-obnova-databáze-active-directory)
- [Studentské úkoly](#studentské-úkoly)
  - [Lab S01 -- Obnova objektů](#lab-s01----obnova-objektů)
  - [Lab S02 -- Snímky databáze Active Directory](#lab-s02----snímky-databáze-active-directory)
  - [Lab S03 -- Auditování změn databáze Active Directory](#lab-s03----auditování-změn-databáze-active-directory)
  - [Lab S04 -- Údržba databáze Active Directory](#lab-s04----údržba-databáze-active-directory)


# Údržba Active Directory

Ani sebelepší konfigurace **Active Directory** nemění nic na faktu, že
je potřeba pravidelně provádět její údržbu. Také je důležité si
uvědomit, že údržba se netýká jen databáze **Active Directory**, ale
obecně všeho co s ní souvisí. Nejde tedy jen o údržbu identit **Active
Directory**, jako jsou účty uživatelů a počítačů, nutných pro
autentizaci, **GPO** objektů, potřebných pro aplikaci zásad skupiny na
tyto uživatele a počítače, nebo objektů míst, spojení a linek, jenž
instruují **KCC** a **ISTG**, jak vytvářet replikační topologii. Je také
nutné zajistit přístup ke zdrojům a službám. Počítače musí být schopny
kontaktovat řadiče domény a jiné servery poskytující požadované služby
(např. *file* a *web* servery), což vyžaduje správné nastavení systému
**DNS** a objektů podsítí. Důležitá je také bezpečnost, jak z pohledu
zabezpečení přístupu ke zdrojům, tak zabezpečení samotných řadičů
domény[^1]. Řadiče domény také musí být schopny rychle a spolehlivě
obsluhovat požadavky klientů, měly by být tedy také pravidelně
monitorovány. To je jen část úkolů, které lze zařadit do celkové údržby
**Active Directory**.

## Údržba databáze Active Directory

Údržba databáze **Active Directory** byla v minulosti značně
problematická. V předchozích verzích systému Windows Server byla totiž
role řadiče domény monolitická. Jediná možnost jak zastavit službu
**Active Directory** byla zastavit celý řadič domény. V praxi to
znamenalo, že v případě údržby databáze **Active Directory** bylo
potřeba vypnout řadič domény a nastartovat ho v režimu obnovení
adresářových služeb (*Directory Services Repair Mode*), ve kterém nejsou
spuštěny služby **Active** **Directory**. Díky tomu nebylo možné
jakkoliv automatizovat údržbu databáze **Active Directory**. Windows
Server 2008 přinesl v tomto ohledu zásadní změnu. Role řadiče domény je
nyní již standardní (ovladatelná) služba, jenž může být kdykoliv
zastavena, restartována nebo spuštěna.

Na rozdíl od standardních služeb je zde ovšem jedno omezení. Aby bylo
možné zastavit službu **AD DS** (*Active Directory Domain Services*), je
potřeba mít v síti přítomen další řadič domény. Každý řadič domény se
před zastavením služby **AD DS** nejprve pokusí spojit s nějakým jiným
řadičem domény a pouze pokud se mu to podaří, zastaví službu **AD DS**.
Toto chování zajišťuje, že je v síti vždy přítomen alespoň jeden řadič
domény.

Potřeba provádění údržby databáze **Active Directory** je následující.
Při přidávání nových záznamů (objektů) do databáze dochází k alokaci
místa pro jejich uložení. V případě mazání záznamů ale není toto
alokované místo uvolněno. Pro jeho uvolnění musí být provedeno tzv.
*zkompaktnění* [^2](*compaction*) databáze. **Active Directory** sice
provádí údržbu své databáze, ale pouze ve formě přesunu záznamů, aby
byly lépe (rychleji) přístupné, neuvolňuje tedy žádné místo.

## Ochrana Active Directory

Ochrana **Active Directory** se samozřejmě týká primárně ochrany dat,
tedy ochrany objektů uložených v databázi **Active Directory**. Asi
nejvíce kritické jsou bezpečnostní objekty (*security principals*).
Každý bezpečnostní objekt (účet uživatele či počítače, skupina apod.)
obsahuje unikátní **SID** (*security identifier*) identifikátor. Tento
identifikátor je generován náhodně pro každý vytvářený bezpečnostní
objekt. Pokud je tedy nějaký bezpečnostní objekt smazán a poté vytvořen
objekt nový, se stejnými hodnotami atributů, budou jejich **SID**
identifikátory odlišné a pro **Active Directory** to budou dva zcela
odlišné objekty. Jednou smazaný bezpečnostní objekt není tedy možné již
znova vytvořit, tak aby měl zachovány informace o příslušnosti do
skupin, o přístupu ke zdrojům, o uložených heslech a certifikátech a o
řadě dalších věcí. Všechny tyto informace jsou ztraceny smazáním
bezpečnostního objektu a proto je důležité účty a podobné objekty raději
zakazovat než mazat. Takto nehrozí nebezpečí jejich zneužití a mohou být
v případě potřeby opět použity (např. když by se uživatel vrátil, nebo
jiný uživatel nastoupil na jeho místo).

Díky replikaci poskytuje **Active Directory** dobrou ochranu proti
nečekané ztrátě dat[^3], veškerá data jsou vlastně zálohována na každém
z řadičů domény. Replikace ale může způsobit také problémy. Pokud je
nějaký objekt vymazán z **Active Directory**, dojde k jeho vymazání i na
všech ostatních řadičích domény. Pak je jedinou možností obnova **Active
Directory** databáze. **Active Directory** ovšem nabízí i jiné možnosti
ochrany nebo následné obnovy dat:

-   **Ochrana objektů před smazáním**. Každý vytvořený objekt **Active
    Directory** může být chráněn proti smazání. Tato ochrana se zapíná
    na záložce Object[^4] zaškrtnutím možnosti Protect object from
    accidental deletion. Většina vytvářených objektů má tuto možnost po
    vytvoření zakázanou, jen kontejnery jako organizační jednotky ji
    mají povolenou pro větší ochranu struktury **Active Directory**.
    Objekt chráněný před smazáním nemůže být smazán ani přesunut,
    nejdříve musí být vždy zrušena jeho ochrana. Prakticky tato ochrana
    nedělá nic jiného, než že nastaví dvě Deny oprávnění (Deny Delete a
    Deny Delete subtree) pro skupinu Everyone.

-   **Auditovaní změn**. Systémy Windows Server 2008 a novější
    protokolují celkem čtyři kategorie přístupu k adresářovým službám. Z
    hlediska ochrany objektů je asi nejdůležitější auditovaní
    změn v **Active Directory** (*Directory Service Changes*), jenž
    protokoluje staré a nové hodnoty atributů objektů, které byly
    vytvořeny, změněny, přesunuty či obnoveny. Tyto hodnoty jsou
    zaznamenávány do protokolu událostí adresářových služeb (*Directory
    Services Event Log*). Pro každou změnu jsou zaprotokolovány alespoň
    dvě události, kdy první obsahuje starou hodnotu a druhá novou
    hodnotu nějakého atributu. Tyto informace mohou být použity pro
    opravu nesprávně změněných hodnot atributů objektů.

-   **Obnova objektů**. Pokud je nějaký objekt **Active Directory**
    smazán, není ihned fyzicky odstraněn z databáze **Active
    Directory**, ale je přesunut, na určitou dobu, do speciálního
    kontejneru Deleted Objects. Objekty obsažené v tomto kontejneru je
    možné kdykoliv obnovit a označují se jako tzv. *tombstoned* objekty
    (smazané, ale ne odstraněné objekty, které se od původních objektů
    liší nastaveným atributem **isDeleted**). Jelikož je kontejner
    Deleted Objects skrytý, je pro obnovu potřeba používat nástroje,
    které vidí i skryté kontejnery jako např. **Ldp.exe** nebo jiné
    speciální nástroje. Ve výchozím nastavení jsou *tombstoned* objekty
    uchovávány 180 dní, pokud není tato doba změněna nebo nejsou
    provedeny některé operace pročišťující databázi **Active
    Directory**. I přesto, že obnovené objekty mají zachovány hodnoty
    většiny svých atributů, včetně **SID** identifikátorů, některé
    informace, jako např. členství ve skupinách, nemusí být již
    přítomny.

-   **Záloha a obnova databáze**. Systém Windows Server od verze 2008
    obsahuje **Windows Server Backup**, jenž lze použít k zálohování
    nebo obnovení databáze **Active Directory**.

## Záloha a obnova databáze Active Directory

Obnova objektů nemusí být často ideální metodou pro obnovu dat. Obnovené
objekty obecně neobsahují veškeré informace a hodnoty atributů, jenž
měly před svým smazáním. Je potřeba je znova doplnit, aby se objekt
dostal do stejného stavu, v jakém byl před svým smazáním. Tyto informace
a hodnoty již ale nemusí být známy. Kromě toho, v případě velkého
množství objektů, ani nemusí být možné je všechny obnovit. Obnovením
zálohy databáze **Active Directory** se obnoví veškeré objekty spolu se
všemi jejich atributy a také i všechny ostatní informace jako např.
členství ve skupinách. Pro zálohování a obnovení databáze **Active
Directory** lze použít **Windows Server Backup**.

Velkým problémem v předchozích verzích systému Windows Server byla
nemožnost zobrazení obsahu jednotlivých záloh databáze **Active
Directory**. Nešlo tedy nijak určit, zda jsou objekty, které jsou
potřeba obnovit, opravdu přítomny v dané záloze. Windows Server od verze
2008 obsahuje nástroj **AD DS Database mounting tool**, jenž umožňuje
zobrazit a procházet obsah záloh databáze **Active Directory**.

Z hlediska zálohování nemusí být zálohována jen samostatná databáze
**Active Directory**. **Windows Server Backup** umožňuje zálohovat celý
server (včetně operačního systému) nebo jen jeho specifické části jako
např. data stavu systému (*System State Data*). Z hlediska obnovy
databáze **Active Directory** je potřeba rozlišovat dva typy obnovy:

-   **Autoritativní obnova**. Při autoritativní obnově budou data
    obnovena na daný řadič domény a tento řadič domény aktualizuje
    pomocí replikace data na všech ostatních řadičích domény.

-   **Neautoritativní obnova**. Při neautoritativní obnově budou opět
    data obnovena na daný řadič domény, ale tato data budou
    aktualizována replikací z ostatních řadičů domény, jakmile bude daný
    řadič domény zpět k dispozici (*online*).

Kromě zálohy a obnovy databáze **Active Directory** nabízí Windows
Server ještě možnost tzv. instalace z média (**IFM**, *Install From
Media*). **IFM** umožňuje vytvořit speciální kopii databáze **Active
Directory** (souboru **Ntds.dit**), jenž může být použita při instalaci
nového řadiče domény jako alternativní zdroj dat namísto replikace.
Tímto se může výrazně snížit množství replikovaných dat při instalaci
daného řadiče domény.

## Záloha databáze Active Directory

Oproti předchozím verzím systému Windows Server došlo u Windows Server
2008 k několika dosti podstatným změnám ohledně zálohování. Navíc také
Windows Server 2008 R2 přinesl další úpravy a novinky v této oblasti.
Pro maximálně efektivní vytváření záloh je vhodné dobré znát veškerá
omezení a možnosti zálohování.

Zálohy mohou být vytvářeny dvěma způsoby. Buď pomocí **Windows Server
Backup** nebo pomocí nástroje **Wbadmin.exe** (*Windows Backup
Administration*). Oba tyto nástroje jsou součásti (*features*) systému
Windows Server 2008 (a novějších) a musí být před prvním použitím
nejprve nainstalovány. Zálohy mohou být vytvářeny automaticky (v
pravidelných intervalech) i manuálně. Automatické zálohy ale nemohou být
prováděny členy skupiny Backup Operators, ti mohou provádět jen manuální
zálohování. Jen členové skupiny Administrator na daném počítači mohou
nastavit automatické zálohování, což v případě normálních řadičů domény
jsou ale všichni členové skupiny Domain Admins, tedy správci domény.

Ve Windows Server lze provádět celkem dva typy záloh:

-   **Záloha celého serveru** (*Full Server Backup*). Tato záloha
    zahrnuje veškerá data všech oddílů pevných disků daného serveru.
    Není možné zálohovat jednotlivé soubory ani adresáře, což se brzy
    ukázalo jako velice omezující a vedlo k zbytečně velkým zálohám. Od
    Windows Server 2008 R2 již umožňuje vybírat i jednotlivé soubory a
    adresáře. Navíc lze specifikovat soubory, které nebudou zahrnuty do
    zálohy na základě jejich typu (přípony) nebo cesty.

-   **Záloha kritických oddílů** (*Critical Volume Backup*). Tato záloha
    obsahuje veškerá data potřebná pro obnovu doménových služeb **Active
    Directory** (**AD DS**). Přesněji tento typ zálohy zahrnuje data
    následujících oddílů:

    -   **Systémového oddílu**. Oddíl obsahující kořenový adresář systému Windows.

    -   **Bootovacího oddílu**. Oddíl obsahující soubory nutné pro start systému Windows. Ve většině případů je tento oddíl totožný s oddílem systémovým.

    -   **Oddílu, jenž obsahuje databázi Active Directory**. Ve výchozím nastavení to je systémový oddíl.

    -   **Oddílu zahrnujícího protokoly Active Directory**. Ve výchozím nastavení opět systémový oddíl.

    -   **Oddílu hostujícího adresář SYSVOL**. Ve výchozím nastavení zase systémový oddíl.

Zálohy nemohou být uloženy na páskové jednotky ani na USB Flash disky,
pouze na síťové a odnímatelné (externí) disky nebo na média CD a DVD. Od
Windows Server 2008 R2 je možné provést zálohu také na oddíly interních
disků, do sdíleného adresáře a také na virtuální a dynamické disky. Při
uložení zálohy do sdíleného adresáře bude ovšem vždy udržována pouze
jediná verze zálohy.

Windows Server 2008 R2 navíc zjednodušil správu a práci s úplnými a
inkrementálními zálohami. **Windows Server Backup** nyní vytváří ve
výchozím nastavení inkrementální zálohy, které se chovají jako úplné
zálohy. Veškerá data lze tedy obnovit z jediné zálohy, i když je tato
záloha jen inkrementální. Dále také dochází k automatickému mazání
starých záloh, bez potřeby manuálního zásahu uživatele. Kromě toho také
obsahuje sadu nástrojů (*cmdletů*) pro **PowerShell**, které umožňují
automatizovat zálohování pomocí skriptů. Případně lze také využít
nástroj **Wbadmin.exe**, jenž poskytuje nyní stejné možnosti jako
**Windows Server Backup**.

## Záloha stavu systému

Stav systému (*System State*) je sada dat potřebná pro chod systému
Windows a pro plnění některých rolí. V případě řadiče domény zahrnuje
stav systému:

-   **Registr**.

-   **Databázi registrovaných COM+ tříd** (*COM+ Class Registration database*).

-   **Bootovací soubory**.

-   **Systémové soubory, které jsou pod ochranou zdrojů systému Windows** (**WRP**, *Windows Resource Protection*). Zde standardně patří většina systémových souborů systému Windows.

-   **Databázi Active Directory**. Tedy soubor **Ntds.dit**.

-   **Adresář SYSVOL**.

Pokud jsou na serveru nainstalovány i jiné role, stav systému bude vždy
obsahovat první čtyři výše zmíněné části a dále:

-   **Databázi certifikačních služeb Active Directory** (**AD CS**).
    Pokud server plní roli **AD CS** (*Active Directory Certification
    Services*).

-   **Informace o výpočetním klusteru**. Pokud je nainstalována služba
    Microsoft Failover Cluster.

-   **Konfigurační soubory IIS**. Pokud server plní roli webového
    serveru (*Web Server*).

Ve Windows Server 2008 bylo možné zálohovat stav systému pouze pomocí
nástroje **Wbadmin.exe**, něšlo tedy pro zálohování použít **Windows
Server Backup**. Ten sice umožňoval zálohovat stav systému, ale pouze v
rámci zálohování celých oddílů disků. **Windows Server Backup** bylo ale
možné využít pro obnovu pouze stavu systému (bez ostatních dat ze
zálohovaných oddílů).

Windows Server 2008 R2 přinesl v tomto ohledu podstatná zlepšení.
**Windows Server Backup** tak nyní umožňuje zálohovat stav systému
samostatně. Navíc lze se stavem systému uložit i další data. Dále je
také možné vytvářet inkrementální zálohy stavu systému. Tyto zálohy jsou
rychlejší a vyžadují méně místa. Inkrementální zálohy využívají stínové
kopie (*shadow copies*) pro verzování různých verzí souborů namísto
jednotlivých adresářů pro každou verzi souboru.

## Obnova databáze Active Directory

I přesto, že od Windows Server 2008 lze roli řadiče domény (**AD DS**
službu) ovládat jako standardní službu, nelze tuto službu jednoduše
zastavit a provést obnovu databáze **Active Directory**. Obnovu je možné
provést pouze v prostředí **WinRE** (*Windows Recovery Environment*)
nebo v **DSRM** (*Directory Services Restore Mode*) režimu.

V **DSRM** režimu lze provádět jen autoritativní a neautoritativní
obnovy databáze **Active Directory**. Tento režim je přístupný v
pokročilých možnostech bootování (*Advanced Boot Options*) na všech
řadičích domény a k nastartování řadiče domény v tomto režimu je
potřebné heslo pro **DSRM** režim. Toto heslo se nastavuje při
povyšování serveru do role řadiče domény a změnit lze pouze po
nastartování řadiče domény v **DSRM** režimu.

**WinRE** prostředí umožňuje provádět obnovy celého systému (včetně
databáze **Active Directory**, je-li přítomná). **WinRE** prostředí může
být buď nainstalováno lokálně (stejně jako např. konzole pro obnovu)
nebo spuštěno z instalačního média.

Před obnovou databáze **Active Directory** je vždy vhodné nejprve
zjistit, zda daná záloha obsahuje potřebná data (objekty). K tomuto
účelu lze nyní využít nástroj **AD DS Database mounting tool**. Tento
nástroj pracuje se snímky (*snapshots*) databáze **Active Directory** a
umožňuje zobrazit jejich obsah. Snímky jsou vytvářeny při každé záloze
databáze **Active Directory** a jsou identifikovány pomocí **GUID**.
Nástroj **AD DS Database mounting tool** je součástí nástroje
**ntdsutil.exe**.

Samotnou obnovu databáze **Active Directory** lze pak provést
neautoritativně nebo autoritativně. První typ obnovy slouží hlavně v
případech externího poškození databáze (např. selháním disku), kdy
nedošlo ke ztrátě dat **Active Directory** (data jsou pořád přítomná na
ostatních řadičích domény), ale pouze k poškození dat u jednoho řadiče
domény. Po obnovení těchto dat jsou tato data aktualizována z ostatních
řadičů domény. Druhý typ slouží k obnovení ztracených dat **Active
Directory**. Takových dat, která již nejsou přítomná na žádném řadiči
domény. Od neautoritativní obnovy se liší pouze tím, že po obnově jsou
data označena jako autoritativní. V praxi to znamená nastavení čísla
**USN** (*Update Sequence Number*), jenž říká ostatním řadičům domény,
že jsou tato data novější než stávající. Navíc u obou typů obnovy nemusí
být obnovena celá databáze, je možné obnovit pouze její část.

## Ochrana řadičů domény virtualizací

Řadiče domény jsou ideální kandidáti pro virtualizaci pomocí
**Hyper-V**, jelikož poskytují čistě síťové služby. Virtuální stroje je
mnohem jednodušší ochraňovat, obnovovat a obecně s nimi jakkoliv
manipulovat. Pokud selže virtuální stroj plnící roli řadiče domény,
stačí se vrátit k jeho předchozí verzi, nastartovat ji a nechat
replikaci provést aktualizaci **Active Directory**. Tento postup
zajišťuje asi nejrychlejší a nejsnadnější obnovu **Active Directory**.

Ochrana disků virtuálních strojů, které jsou normálními soubory, může
být navíc zajištěna pomocí **VSS** (*Volume Shadow Copy Service*).
**VSS** umožňuje automaticky vytvářet snímky obsahu těchto disků v
pravidelných intervalech. Pokud dojde k poškození dat na nějakém z
těchto disků, lze se jednoduše vrátit k jeho dřívější verzi přes záložku
Předchozí verze (*Previous Versions*) ve vlastnostech souboru, jenž
reprezentuje daný disk virtuálního stroje.

Služba **VSS** by vždy měla běžet na serverech, na kterých běží
virtuální stroje. **VSS** je systém, který umožňuje provádět zálohy
oddílů, i když aplikace stále na tyto oddíly zapisují. Je implementován
jako sada **COM** rozhraní a je k dispozici i u **Server Core**
instalace.

## Active Directory koš

**Active Directory** koš, představený ve Windows Server 2008 R2, značně
rozšiřuje možnosti uchovávání a obnovy omylem smazaných objektů
**Active Directory** bez nutnosti jejich obnovy ze záloh, restartování
**AD DS** služeb nebo i celého řadiče domény. Pokud je **Active
Directory** koš povolen, přímé (*non-link-valued*) i nepřímé
(*link-valued*) atributy smazaných objektů **Active Directory** jsou
zachovány a obnoveny do přesně stejného logického stavu, ve kterém byly
v okamžiku těsně před svým smazáním. Tedy, na rozdíl od obnovy
*tombstoned* objektů, jsou kromě hodnot atributů těchto objektů obnoveny
také např. informace o členství ve skupinách a k nim vázané oprávnění
pro přístup ke zdrojům. Jsou tedy obnoveny i informace, jenž nejsou
přímo uloženy v rámci daných objektů, ale jsou s nimi nějak svázány.

**Active Directory** koš je možné použít jak pro doménové služby
**Active Directory** (**AD DS**), tak i pro adresářové služby **Active
Directory** (**AD LDS**) a ve výchozím nastavení je zakázán. Pro
povolení **Active Directory** koše je potřeba mít funkční úroveň lesa
Windows Server 2008 R2 nebo vyšší a aktualizované schéma
**Active Directory**[^5]. Potřebné aktualizace schématu se provádějí
během přípravy lesa příkazem **adprep /forestprep**, během přípravy
domény příkazem **adprep /domainprep /gpprep** a v případě existence
**RODC** řadičů v doméně ještě vykonáním příkazu **adprep /rodcprep**.
U **AD LDS** se místo schématu musí aktualizovat **AD LDS** konfigurace
pomocí nástroje **Ldifde.exe**. Povolení **Active Directory** koše je
nevrátná operace, jakmile je tento koš jednou povolen, nelze ho již
vypnout.

Pokud je **Active Directory** koš povolen, rozlišují se celkem čtyři
typy objektů **Active Directory**:

-   **Živý objekt** (*Live object*). Živé objekty jsou všechny nesmazané
    objekty v **Active Directory**.

-   **Smazaný objekt** (*Deleted object*). Pokud je živý objekt smazán,
    stane se z něj smazaný objekt (stane se tzv. *logicky smazaným*
    objektem). Veškeré přímé a nepřímé atributy daného objektu jsou
    zachovány a je přesunut do kontejneru Deleted Objects. V tomto
    kontejneru zůstává po dobu životnosti smazaných objektů (ve výchozím
    nastavení 180 dnů). Během této doby lze objekt obnovit (*undelete*)
    nebo autoritativně obnovit (*restore*).

-   **Recyklovaný objekt** (*Recycled object*). Pokud vyprší doba
    životnosti smazaného objektu, stane se recyklovaným objektem.
    Většina atributů tohoto objektu je odstraněna. Které atributy mají
    být ponechány, je možné specifikovat ve schématu **Active
    Directory**. Recyklovaný objekt je stále umístěn v kontejneru
    Deleted Objects, ale není viditelný, a zůstává v něm, dokud nevyprší
    jeho doba životnosti (ve výchozím nastavení 180 dnů).

-   **Odstraněný objekt** (*Physically deleted object*). Pokud vyprší
    doba životnosti recyklovaného objektu, je tento objekt fyzicky
    smazán z databáze **Active Directory**. O odstraňování recyklovaných
    objektů se stará GC (*Garbage Collector*), jenž v pravidelných
    intervalech pročišťuje databázi **Active Directory**.

Doby životnosti smazaných a recyklovaných objektů lze kdykoliv změnit,
doporučuje se ovšem nenastavovat tuto dobu kratší než 180 dnů. V případě
obnovy smazaných **GPO** objektů nebo Exchange objektů platí omezení, že
žádná aplikačně-specifická data pro tyto objekty, jenž nebyla uložena
v databázi **Active Directory**, nebudou obnovena.

Od Windows Server 2012 je možné zapnout **Active Directory** Koš nejen
pomocí **Powershellu**, ale také pohodlněji v **Active Directory
Admninistrativ Center**.

---

# AutomatedLab

```
$labName = 'E11'
New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV -VmPath "E:\AutomatedLab-VMs"

$adminPass = 'root4Lab'

Set-LabinstallationCredential -username root -password $adminPass
Add-LabDomainDefinition -Name testing.local -AdminUser root -AdminPassword $adminPass
Add-LabDomainDefinition -Name child.testing.local -AdminUser root -AdminPassword $adminPass


Add-LabMachineDefinition -Name w2022-dc1  -Memory 4GB -Processors 8  -OperatingSystem 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)' -Roles RootDC -DomainName testing.local
Add-LabMachineDefinition -Name w2022-dc2  -Memory 4GB -Processors 8  -OperatingSystem 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)' -Roles DC     -DomainName testing.local
Add-LabMachineDefinition -Name w2022-child-dc1  -Memory 4GB -Processors 8  -OperatingSystem 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)' -Roles FirstChildDC  -DomainName child.testing.local 

Install-Lab

Invoke-LabCommand -ActivityName 'Create Users' -ScriptBlock {
    $password = 'root4Lab' | ConvertTo-SecureString -AsPlainText -Force

    New-ADUser -Name student -SamAccountName Student -AccountPassword $password -Enabled $true

    $Simpsons = New-ADGroup -Name "Simpsons" -SamAccountName Simpsons -GroupCategory Security -GroupScope Global -DisplayName "Simpsons" -Description "Members of this group are Simpsons" -PassThru

    $Homer = New-ADUser -Name Homer  -AccountPassword $password -Enabled $true -PassThru
    $Bart = New-ADUser -Name Bart -AccountPassword $password -Enabled $true -PassThru

    Add-ADGroupMember -Identity $Simpsons -Members $Homer
    Add-ADGroupMember -Identity $Simpsons -Members $Bart
    
    $dcTesting = [ADSI]"LDAP://DC=testing,DC=local"
    $ouIW2 = $dcTesting.Create("OrganizationalUnit", "OU=IW2")
    $ouIW2.SetInfo()

    $userA = $ouIW2.Create("user", "CN=UserA")
    $userA.Put("sAMAccountName", "UserA") 
    $userA.SetInfo()
    $userA.SetPassword("aaaAAA111")
    $userA.SetInfo()
    $userA.InvokeSet("AccountDisabled", $false)
    $userA.SetInfo()

    $userA = $ouIW2.Create("user", "CN=UserB")
    $userA.Put("sAMAccountName", "UserB") 
    $userA.SetInfo()
    $userA.SetPassword("aaaAAA111")
    $userA.SetInfo()
    $userA.InvokeSet("AccountDisabled", $false)
    $userA.SetInfo()

    $ouIW2 = [ADSI]"LDAP://OU=IW2,DC=testing,DC=local"
    $ouIW2.deleteTree()

} -ComputerName w2022-dc1


Show-LabDeploymentSummary
```

---

# Společné úkoly

-   Upravte nastavení RAM a CPU dle použitých PC

## Lab LS00 -- konfigurace virtuálních stanic

Připojte sítové adaptéry stanic k následujícím virtuálním přepínačům:


| **Adaptér (MAC suffix)** | **LAN**  |
| ------------------------ | -------- |
| **w2022-dc1**            | Internal |
| **w2022-dc2**            | Internal |
| **w2022-child-dc1**      | Internal |

-   V případech, kdy je potřeba přistupovat na externí síť, připojte
    adaptér **LAN1** k přepínači *Default switch*.

# Lektorské úkoly

## Lab L01 -- Ochrana Active Directory

> **Cíl cvičení**
>
> Seznámení s možnostmi ochrany objektů v AD
>
> **Potřebné virtuální stroje**
>
> **w2022-dc1** 
>
> **w2022-dc2** 

Projděte možnosti ochrany objektů databáze **Active Directory**. Nejprve
ukažte ochranu před smazáním objektů v **ADUC** konzoli (Záložka Object,
možnost Protect object from accidental deletion, musí být zapnuté
Advanced Features) a zmiňte, že lze takto ochraňovat všechny objekty
**Active Directory**, ne jen ty co se zobrazují v **ADUC**.

Zmiňte možnosti auditování přístupu k objektům **Active Directory**,
jejich změn a replikace. Hlavně řekněte, že při auditování změn se
ukládají do protokolů událostí informace o starých a nových hodnotách
změněného atributu, které lze využít jako určitou formu zálohy.

Doplňte informace o obnově *tombstoned* objektů a **Active Directory
koši**. Hlavně zdůrazněte, že **AD koš** uchovává veškeré, přímé i
nepřímé, atributy smazaných objektů a že recyklované objekty odpovídají
u **AD koše** *tombstoned* objektům. Upozorněte, že **GPO** objekty
nemusí být obnoveny se všemi předchozími informacemi a důrazně se
nedoporučuje to provádět. Ukažte možnosti zálohy **GPO** objektů v
**GPMC** konzoli (pravým na kontejner Group Policy Objects → Back Up
All...) a také obnovy (pravým na kontejner Group Policy Objects → Manage
backups...).

## Lab L02 -- Záloha a obnova databáze Active Directory

> **Cíl cvičení**
>
> Zálohovat a následně obnovit databázi **Active Directory**
>
> **Potřebné virtuální stroje**
>
> **w2022-dc1** 
>
> **w2022-dc2** 
>
> **w2022-child-dc1** 
>
> **Další prerekvizity**

-   Sdílený adresář **share** na **w2022-child-dc1**, do kterého může
    zapisovat uživatel **root**

-   Skupina **Simpsons** v doméně **testing.local**, účty uživatelů
    **homer** a **bart** v doméně **testing.local**

    -   System state záloha **w2022-dc1** v **\\\\w2022-child-dc1\\share**
        (pro urychlení)

1.  Přihlaste se na **w2022-dc1** jako **testing\\root**

2.  Zálohujte databázi **Active Directory**

    a.  Spusťte **Windows Server Backup**

    1.  Start → Administrative Tools → **Windows Server Backup**

    b.  V menu vyberte Action a zvolte Backup Once...

    c.  V části Backup Options vyberte Different options a pokračujte
        Next \>

    d.  V další části Select Backup Configuration zvolte Custom a
        pokračujte Next \>

    e.  V následující části Select Items for Backup zvolte Add Items

    f.  V seznamu věcí pro zálohování vyberte System state a potvrďte OK

    -   Zálohování stavu systému přes **Windows
            Server Backup** je k dispozici až od Windows Server 2008 R2,
            u starších verzí lze použít **Wbadmin.exe**

    -   Záloha stavu systému od Windows Server 2008 R2
            již inkrementální

    -   Explicitní vyloučení souborů a adresářů ze
            zálohy (záložka Exclusions v Advanced Settings) nemá vliv na
            zálohování stavu systému, tedy nelze vyloučit adresáře ani
            soubory patřící ke stavu systému

    g.  Pokračujte Next \>

    h.  V části Specify Destination Type zvolte Remote shared folder a
        pokračujte Next \>

    i.  V další části Specify Remote Folder zadejte u Location adresář
        **\\\\w2022-child-dc1\\share**, pod Access Control ponechte Inherit
        a pokračujte Next \>

    -   Zobrazí se upozornění, že se již v daném umístění záloha vyskytuje, potvrďte OK

    -   Zálohování do sdíleného adresáře je možné až od
            Windows Server 2008 R2 a také, že se v tomto případě
            uchovává jen jediná verze

    -   Zadaný sdílený adresář musí být vzdálený,
            tedy musí se nacházet na jiném počítači, než který
            zálohujeme, jinak dojde k chybě při zálohování

    -   V případě selhání zálohování do sdíleného
            adresáře mohou být ztracena předtím zálohovaná data, jelikož
            se stará verze přepisuje novou

    j.  Proveďte zálohu stavu systému pomocí Backup

    -   Záloha trvá přibližně 15 min

    k.  Po dokončení zálohování uzavřete průvodce pomocí Close

3.  Smažte skupinu **Simpsons** a uživatele **homer** a **bart**

4.  Proveďte autoritativní obnovu databáze Active Directory

    a.  Restartujte **w2022-dc1** v **DSRM** (*Directory Services Restore
        Mode*) režimu

    1.  Z příkazové řádky spusťte `shutdown -o -r`, alternativně `bcdedit /set {bootmgr} displaybootmenu yes` -> restartujte -> F8

        -   Tip: Pokud bude protestovat, že -o je nevalidní, odhlaste se a znova se přihlaste
        -   Tip: Pokud nebude HyperV fungovat, vypněte "Enhanced session" a skuste znova

    2.  Systém se po krátké chvíli restartuje a následně ukáže
            nabídku se základními možnostmi spuštění

    3.  V nabídce zvolte Troubleshoot -- Startup Settings a potvrďte
            tlačítkem Restart

        -   Po restartu se zobrazí nabídka **Advanced Boot Options**

        -   Na starších verzích Windows lze tuto nabídku vyvolat klávesou **F8** na začátku bootování systému Windows

        4.  Vyberte **Directory Services Repair Mode**

        5.  Přihlaste se lokálně jako uživatel **root**

        -   **w2022-dc1\\administrator** nebo **.\\administrator**
        -   Obnova stavu systému se musí provádět v
                **DSRM** režimu

    b.  Spusťte **Windows Server Backup**

    6.  Start → Administrative Tools → **Windows Server Backup**

    c.  V levém sloupci vyberte uzel Local Backup

    d.  V menu vyberte Action a zvolte Recover...

    e.  V části Getting Started vyberte A backup stored on another
        location a pokračujte Next \>

    f.  V další části Specify Location Type zvolte Remote shared folder
        a pokračujte Next \>

    g.  V následující části Specify Remote Folder zadejte adresář
        **\\\\w2022-child-dc1\\share** a pak pokračujte Next \> (při výzvě použijte účet **testing\\root**)

    h.  V části Select Backup Date zvolte datum a čas poslední zálohy a
        pokračujte Next \>

    i.  V další části Select Recovery Type zvolte System State a
        pokračujte Next \>

    j.  V následující části Select Location for System State Recovery
        ponechte Original Location, zaškrtněte Perform an authoritative
        restore of Active Directory files a pokračujte Next \>

    -   Autoritativní se liší od neautoritativní jen v
            označení obnovených souborů jako novějších

    k.  Potvrďte dvakrát OK

    l.  ~~Zahajte autoritativní obnovu pomocí Recover a potvrďte Yes~~

    -   Obnovu **neprovádějte**, místo toho se vraťte zpět do části
            Select Recovery Type a obnovte pouze databázi **Active
            Directory** - zvolte Files and folders, pokračujte Next \>,
            najděte soubor **C:\\Windows\\NTDS\\ntds.dit**, Next \>, pod **Destination** dejte `C:\Windows\NTDS\`,
            Recover

5.  Restartujte **w2022-dc1** a zkontrolujte, že byly obnoveny objekty smazané v bodě 3

# Studentské úkoly

## Lab S01 -- Obnova objektů

> **Cíl cvičení**
>
> Obnovit smazané objekty bez a s přítomností **Active Directory** koše
>
> **Potřebné virtuální stroje**
>
> **w2022-dc1** 
>
> **w2022-dc2** 
>
> **Další prerekvizity**
>
> Účty uživatelů **bart** a **homer** v doméně **testing.local**, jenž jsou členy skupiny **Simpsons**

1.  Vymažte účet uživatele **bart**

    -   Objekt se stane tzv. *tombstoned* objektem

2.  Obnovte účet uživatele **bart**

    a.  Spusťte nástroj **ldp.exe**

    b.  V menu vyberte Connection a pak zvolte Connect...

    c.  Do pole Server zadejte **w2022-dc1.testing.local** a připojte se
        pomocí OK

    d.  V menu opět vyberte Connection a zvolte Bind...

    e.  Pod Bind type zvolte Bind as currently logged on user a potvrďte
        OK

    f.  V menu vyberte Options a zvolte Controls

    g.  Pod Control Type zvolte Server a pak v Load Predefined seznamu
        vyberte Return deleted objects, potvrďte OK

    -   Ujistěte se, že máte v seznamu Active Controls jen záznam
            1.2.840.113556.1.4.417, přebytečné odeberte tlačítkem \<\<
            Check Out

    h.  V menu vyberte View a zvolte Tree

    i.  Po pole BaseDN zadejte **cn=Deleted
        Objects,dc=testing,dc=local** a potvrďte OK

    j.  Lokalizujte účet uživatele **bart**, klikněte na něj pravým a
        zvolte Modify

    -   Účet bude začínat **cn=bart\\0ADEL...**

    k.  Do pole Edit Entry Attribute zadejte **isDeleted**, jako
        Operation zvolte Delete a potvrďte pomocí tlačítka Enter

    l.  Do pole Edit Entry Attribute zadejte **distinguishedName**, do
        pole Value zadejte **cn=bart, cn=Users,dc=testing,dc=local**,
        jako Operation zvolte Replace a potvrďte pomocí tlačítka Enter

    m.  Zaškrtněte možnosti Synchronous a Extended níže a proveďte
        příkaz pomocí Run

3.  Ověřte, že byl účet uživatele **bart** skutečně obnoven

    -   Uživatel **bart** nebude členem skupiny **Simpsons**, jelikož se
        tato informace u *tombstoned* objektů neuchovává, stejně jako
        hodnoty řady dalších atributů

    -   Všimněte si, že je účet **zakázán** (*disabled*)

4.  Povolte **Active Directory** koš

    -   Pozor, jakmile je **Active Directory** koš povolen, nelze již
        zpět zakázat

    a.  Pomocí **ADAC** (*Active Directory Administrative Center*)

    1.  Otevřete **ADAC**

        a.  Start → Administrative Tools → **Active Directory Administrative Center**

    2.  V navigačním panelu (vlevo) zvolte **testing (local)**

    3.  V panelu úkolů (vpravo), nebo z kontextové nabídky zvolte
            Enable Recycle Bin ... a 2x potvrďte OK

        -   Aby se změna projevila i v konzoli **ADAC**, je vhodné
                ji ukončit a opět otevřít

    b.  Pomocí **Powershellu** (lze i ve Windows 2008R2)

    1.  Spusťte jako administrátor **Active Directory Module for Windows PowerShell**

        a.  Start → **Administrative Tools**

        b.  Klikněte pravým na **Active Directory Module for Windows
                PowerShell** a zvolte Run as administrator

    2.  Spusťte příkaz `Enable-ADOptionalFeature -Identity "CN=Recycle Bin Feature, CN=Optional Features, CN=Directory Service, CN=Windows NT, CN=Services, CN=Configuration, DC=testing, DC=local\" -Scope ForestOrConfigurationSet -Target \"testing.local\"`

    3.  Potvrďte pomocí **Y**

1.  Vymažte účet uživatele **homer**

    -   Objekt se stane smazaným objektem, nový stav u **Active
        Directory** koše

2.  Obnovte účet uživatele **homer**

    a.  Pomocí **ADAC** (*Active Directory Administrative Center*)

    1.  Otevřete **ADAC**

        a.  Start → Administrative Tools → **Active Directory
                Administrative Center**

    2.  V navigačním panelu (vlevo) zvolte **testing (local)** -- **Deleted Objects**

    3.  Vyberte účet **Homer** a z panelu úkolů (nebo kontextové nabídky) zvolte Restore

        -   Alternativně lze použít Restore To ... pro obnovení do jiného umístění

    b.  Pomocí **Powershellu**

    1.  Spusťte jako administrátor **Active Directory Module for Windows PowerShell**

    2.  Spusťte příkaz `Get-ADObject -Filter {sAMAccountName -eq \"homer\"} -IncludeDeletedObjects | Restore-ADObject`

        -   Objekt lze obnovit také postupem z **bodu** Error! Reference source not found.

    3.  Ověřte, že byl účet uživatele **homer** skutečně obnoven

        -   Uživatel **homer** bude pořád členem skupiny **Simpsons**,
        jelikož **Active Directory** koš uchovává veškeré informace
        (přímé i nepřímé) u smazaných objektů

## Lab S02 -- Snímky databáze Active Directory

> **Cíl cvičení**
>
> Vytvořit snímek databáze Active Directory a zobrazit ho
>
> **Potřebné virtuální stroje**
>
> **w2022-dc1** 
>
> **Další prerekvizity**
>
> Účet uživatele **bart** v doméně **testing.local**

1.  Vytvořte snímek aktuálního stavu databáze **Active Directory**

    a.  Spusťte jako administrátor příkazovou řádku

    b.  Spusťte nástroj `ntdsutil`

    c.  Vyberte databázi **Active Directory** příkazem `activate
        instance NTDS`

    d.  Přejděte do správy snímků příkazem `snapshot`

    e.  Vytvořte nový snímek příkazem `create`

    -   Snímky se také vytvářejí automaticky pří záloze databáze **Active Directory**

2.  Proveďte nějakou změnu v databázi **Active Directory** u uživatele
    **bart**, např. změňte hodnotu atributu Description

3.  Vytvořte LDAP server obsahující dříve vytvořený snímek databáze
    **Active Directory**

    a.  Ve správě snímků (snapshot:) v nástroji `ntdsutil` zobrazte
        seznam všech snímků příkazem `list all`

    -   Seznam obsahuje všechny dostupné snímky (manuálně vytvořené
            či obsažené v zálohách), každý řádek seznamu odpovídá
            jednomu snímku a je ve formátu **\<index\>: \<popis\>
            {\<guid\>}**, kde **\<popis\>** může být datum a čas
            pořízení snímku (zálohy) nebo umístění

    b.  Připojte snímek příkazem `mount \<index\>`, případně `mount \<guid\>`

    -   Použijte **\<index\>** nebo **\<guid\>** posledního snímku ze seznamu snímků, po připojení bude vypsána cesta k připojenému snímku

    c.  Spusťte jako administrátor druhý příkazový řádek

    d.  Spusťte příkaz `dsamain -dbpath \<cesta k databázi ve snímku\>
        -ldapport 65000`

    -   Jako cestu k databázi ve snímku použijte cestu k přípojenému
            snímku (vrácenou při připojení nástrojem ntdsutil), a
            obcyklou cestou k databázi AD. Výsledná cesta by měla být ve
            formátu **C:\\\$SNAP\_\<datum a
            čas\>\_VOLUMEC\$\\Windows\\NTDS\\ntds.dit**

    -   Zvolený port musí být možné použít, tedy nesmí být již
            využíván jinou aplikací, nesmí být blokován či rezervován
            (systémem nebo jinak), doporučuje se používat čísla vyšší
            než **50000**

4.  Zobrazte obsah vytvořeného snímku databáze **Active Directory**

    a.  Otevřete **ADUC** (*Active Directory Users and Computers*)

    1.  Start → Administrative Tools → **Active Directory Users and
            Computers**

    b.  Klikněte pravým na uzel Active Directory Users and Computers a
        zvolte Change Domain Controller...

    c.  Pod Change to zvolte možnost This Domain Controller or AD LDS
        instance a níže zadejte **w2022-dc1:65000**

    -   Pokud bude místo hostitelského jména LDAP serveru zadána jeho IP adresa, nebude možné se k tomuto serveru připojit

    d.  Potvrďte OK

5.  Ověřte, že snímek neobsahuje změny provedené u uživatele **bart** po
    vytvoření snímku

6.  Zavřete okno ADUC připojené k AD LDS **w2022-dc1:65000**

7.  Ukončete LDAP server

    a.  V okně s příkazovou řádkou s `dsamain` stiskněte **Ctrl+C**

8.  Odpojte snímek

    a.  Vraťte se do prvního okna příkazové řádky s nástrojem
        `ntdsutil`

    b.  V nástroji **ntdsutil** odpojte snímek příkazem `unmount \<index\>`, případně `unmount \<guid\>`

    c.  Ukončete nástroj `ntdsutil` příkazy `quit` a `quit`

## Lab S03 -- Auditování změn databáze Active Directory

> **Cíl cvičení**
>
> Povolit a ověřit auditování změn v databázi Active Directory
>
> **Potřebné virtuální stroje**
>
> **w2022-dc1** 
>
> **Další prerekvizity**
>
> Účet uživatele **bart** v doméně **testing.local**

1.  Povolte auditování změn v databázi **Active Directory**

    a.  Otevřete **GPME** (*Group Policy Management Editor*)

    1.  Start → Administrative Tools → **Group Policy Management**

    b.  Klikněte pravým na GPO objekt Default Domain Controllers Policy
        a zvolte Edit...

    c.  Vyberte uzel Computer Configuration \\ Policies \\ Windows
        Settings \\ Security Settings \\ Advanced Audit Policy
        Configuration \\ Audit Policies \\ DS Access

    d.  Klikněte pravým na Audit Directory Service Changes a zvolte
        Properties

    e.  Zaškrtněte Configure the following audit events, pak Success a
        potvrďte OK

    -   Toto nastavení zajistí auditování úspěšných změn v databázi
            **Active Directory**

    f.  Vyberte uzel Computer Configuration \\ Policies \\ Windows
        Settings \\ Security Settings \\ Local Policies \\ Security
        Options

    g.  Klikněte pravým na Audit: Force audit policy subcategory
        settings (Windows Vista or later) to override audit policy
        category settings a zvolte Properties

    h.  Zaškrtněte Define these policy settings a zvolte Enabled a
        potvrďte OK

    -   Toto nastavení zapíná pokročilé zásady auditování, pokud
            není tato zásada povolena, ignorují počítače nastavení
            auditování, jenž jsou obsažená pod uzlem Advanced Audit
            Policy Configuration

    i.  Zavřete Group Policy Management Editor

    j.  Aktualizujte nastavení zásad skupiny příkazem `gpupdate /force`

2.  Ověřte, že auditování změn v databázi **Active Directory** bylo
    povoleno

    a.  Spusťte příkazovou řádku

    b.  Spusťte příkaz `auditpol.exe /get /category:\"DS Access\"`

    c.  Ověřte, že u podkategorie Directory Service Changes je nastavení
        **Success**

3.  Přidejte uživatele **bart** do skupiny Domain Admins

    -   Obecně nedochází k auditování veškerých změn v databázi **Active
        Directory**, zazmenávají se pouze důležitější změny, např. změny
        členství ve skupinách

4.  Ověřte zaznamenání přidání uživatele **bart** do skupiny Domain
    Admins

    a.  Otevřete **Event Viewer**

    1.  Start → Administrative Tools → **Event Viewer**

    b.  Vyberte uzel Windows Logs \\ Security

    c.  Lokalizujte a vyberte poslední událost s Event ID **5136**

    d.  Na záložce Details ověřte, že zaznamenána událost se týká členství ve skupině Domain Admins (hodnota ObjectDN je
        **CN=Domain Admins,CN=Users,DC=testing,DC=local**), že došlo ke
        změně členů této skupiny, neboli že došlo k modifikaci atributu
        member (hodnota AttributeLDAPDisplayName je **member**), a také
        že byt přidán uživatel **bart** (hodnota AttributeValue je
        **CN=bart,CN=Users,DC=testing,DC=local** a hodnota OperationType
        je **%%14674**)

## Lab S04 -- Údržba databáze Active Directory

> **Cíl cvičení**
>
> Provést údržbu databáze Active Directory
>
> **Potřebné virtuální stroje**
>
> **w2022-dc1** 
>
> **Další prerekvizity**
>
> Adresář **C:\\share**

1.  Vypněte doménové služby **Active Directory** (**AD DS**)

    a.  Otevřete konzoli **Services**

    1.  Start → Administrative Tools → **Services**

    b.  Klikněte pravým na Active Directory Domain Services a zvolte Stop

    c.  Potvrďte zastavení ostatních souvisejících služeb pomocí Yes

2.  Proveďte zkompaktnění databáze **Active Directory**

    a.  Spusťte jako administrátor příkazovou řádku

    b.  Spusťte nástroj `ntdsutil`

    c.  Vyberte databázi **Active Directory** příkazem `activate instance NTDS`

    d.  Přejděte do údržby souborů příkazem `files`

    e.  Proveďte *zkompaktnění* databáze příkazem `compact to C:\\share`

    -   Při *zkompaktňování* se vytváří nová databáze **Active Directory**, která již neobsahuje dříve alokované nepotřebné místo

    f.  Ukončete nástroj `ntdsutil` příkazy `quit` a `quit`

3.  Nahraďte starou databázi **Active Directory** její *zkompaktněnou
    formou*

    a.  Smažte staré protokoly příkazem `del C:\\Windows\\NTDS\\\*.log`

    b.  Nahraďte databázi příkazem `copy C:\\share\\ntds.dit\ C:\\Windows\\NTDS\\ntds.dit\`

    c.  Potvrďte přepsání databáze pomocí `Yes`

4.  Ověřte integritu a sémantiku nové databáze **Active Directory**

    a.  Spusťte nástroj `ntdsutil`

    b.  Vyberte databázi **Active Directory** příkazem `activate instance NTDS`

    c.  Přejděte do údržby souborů příkazem `files`

    d.  Spusťte kontrolu integrity databáze příkazem `integrity`

    e.  Vraťte se zpět příkazem `quit`

    f.  Přejděte do části ověřování sémantiky databáze příkazem
        `semantic database analysis`

    g.  Ověřte sémantiku databáze příkazem `go fixup`

    h.  Ukončete nástroj `ntdsutil` příkazy `quit` a `quit`

5.  Zapněte doménové služby **Active Directory** (**AD DS**)

    a.  Otevřete konzoli **Services**

    1.  Start → Administrative Tools → **Services**

    b.  Klikněte pravým na Active Directory Domain Services a zvolte
        Start

[^1]: Nejde jen o zabezpečení systému, který běží na řadiči domény, či
    uživatelských účtů, které se mohou k tomuto řadiči přihlásit, ale i
    o fyzické zabezpečení. Obecně se doporučuje, aby se řadiče domény
    spravovaly jen vzdáleně a byly uloženy na bezpečném místě, kde má
    přístup jen několik pověřených osob

[^2]: *Zkompaktnění* databáze je proces, při kterém se nejprve provede
    *defragmentace* databáze, následovaná její minimalizací. V případě
    **Active Directory** databáze, souboru **Ntds.dit**, je výsledkem
    *defragmentace* přesun veškerých dat na začátek tohoto souboru
    následovaný minimalizací tohoto souboru (ořezání konce souboru, kde
    je nyní situováno všechno, dříve alokované, neuvolněné místo)

[^3]: Nečekanou ztrátou dat je myšleno např. selhání HDD, tedy ztráta
    způsobena mimo systém **Active Directory**

[^4]: Tato záložka je viditelná pouze, pokud jsou povolené pokročilé
    možnosti zobrazení (Advanced Features)

[^5]: V případě čisté instalace lesa s funkční úrovní
    Windows Server 2008 R2 a vyšší již schéma obsahuje veškeré potřebné
    informace a není potřeba ho aktualizovat
