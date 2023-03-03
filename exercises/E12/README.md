- [Active Directory - Vztahy důvěry](#active-directory---vztahy-důvěry)
- [AutomatedLab](#automatedlab)
- [Společné úkoly](#společné-úkoly)
  - [Lab LS00 -- konfigurace virtuálních stanic](#lab-ls00----konfigurace-virtuálních-stanic)
- [Lektorské úkoly {#lektorské-úkoly .IW\_nadpis1}](#lektorské-úkoly-lektorské-úkoly-iw_nadpis1)
  - [Lab L01 -- ADDT (Active Directory Domains and Trusts)](#lab-l01----addt-active-directory-domains-and-trusts)
  - [Lab L02 -- Vytvoření vztahů důvěry](#lab-l02----vytvoření-vztahů-důvěry)
- [Studentské úkoly {#studentské-úkoly .IW\_nadpis1}](#studentské-úkoly-studentské-úkoly-iw_nadpis1)
- [Bodované úkoly {#bodované-úkoly .IW\_nadpis1}](#bodované-úkoly-bodované-úkoly-iw_nadpis1)


# Active Directory - Vztahy důvěry

V případě pracovní skupiny si každý počítač uchovává vlastní úložiště
identit (*identity store*) ve formě **SAM** (*Security Accounts
Manager*) databáze. Autentizace uživatelů probíhá oproti tomuto úložišti
identit a pouze identity přítomné v tomto úložišti mohou mít definován
přístup ke zdrojům na daném počítači. Pokud je počítač připojen do
domény, vytvoří se vztah důvěry (*trust relationship*, *trust*) mezi
tímto počítačem a doménou. Tento vztah důvěry způsobí, že uživatelé již
nejsou autentizování lokálním systémem oproti lokálnímu úložišti
identit, ale autentizačními službami domény (tedy **AD DS**) oproti
doménovému úložišti identit (tedy databázi **Active Directory**).
Připojený počítač také dovolí identitám z domény přistupovat k jeho
lokálním zdrojům a využívat je.

Tento základní koncept lze samozřejmě rozšířit i na vztahy důvěry mezi
jednotlivými doménami. Vztah důvěry mezi dvěma doménami umožňuje jedné
doméně věřit autentizačním službám a úložišti identit druhé domény a
používat identity z druhé domény k zabezpečení zdrojů. Každý vztah
důvěry zahrnuje právě dvě domény, důvěřující (*trusting*) doménu a
důvěryhodnou (*trusted*) doménu. Důvěryhodná doména obsahuje úložiště
identit a poskytuje autentizační služby pro uživatele z tohoto úložiště.
Pokud se uživatel z důvěryhodné domény přihlásí nebo připojí ke zdroji
(počítači, souboru atd.) v důvěřující doméně, nemůže být v této doméně
autentizován, jelikož není přítomen v úložišti identit důvěřující
domény. V tomto případě důvěřující doména přenechá autentizaci nějakému
řadiči z důvěryhodné domény.

Protože důvěřující doména důvěřuje identitám z důvěryhodné domény, může
důvěřující doména používat identity z důvěryhodné domény k zabezpečení
svých vlastních zdrojů. Uživatelům z důvěryhodné domény lze přidělovat
práva (*rights*) v důvěřující doméně, např. je možné uživatelům
z důvěryhodné domény povolit přihlašovat se na počítače v důvěřující
doméně. Uživatelé a globální skupiny z důvěryhodné domény mohou být také
přidáni do doménově lokálních skupin v důvěřující doméně, případně i
přímo do **ACL** seznamů jednotlivých zdrojů v důvěřující doméně.

Některé vztahy důvěry jsou vytvářeny automaticky, jiné musí být
vytvořeny manuálně. V obou případech jsou ale tyto vztahy
charakterizovány dvěma vlastnostmi:

-   **Tranzitivita**. Vztahy důvěry mohou, nebo nemusí, být tranzitivní.
    Pokud doména **A** důvěřuje doméně **B** a doména **B** důvěřuje
    doméně **C** a oba tyto vztahy důvěry jsou tranzitivní, pak také
    doména **A** důvěřuje doméně **C**. V opačném případě, kdy některý
    ze vztahů není tranzitivní, to neplatí, doména **A** tedy nedůvěřuje
    doméně **C**.

-   **Směr**. Vztahy důvěry mohou být jednosměrné (*one-way*) nebo
    obousměrné (*two-way*). V případě jednosměrného vztahu důvěry mohou
    uživatelé z důvěryhodné domény přistupovat ke zdrojům v důvěřující
    doméně, ovšem uživatelé z důvěřující domény nemohou přistupovat ke
    zdrojům v důvěryhodné doméně. U obousměrného vztahu důvěry mohou
    i uživatelé z důvěřující domény přistupovat ke zdrojům v důvěryhodné
    doméně.

V lese si všechny domény navzájem důvěřují. Přesněji kořenová doména
každého doménového stromu v daném lese důvěřuje kořenové doméně lesa[^1]
a každá podřízená (*child*) doména důvěřuje své nadřízené (*parent*)
doméně. Všechny tyto vztahy důvěry jsou tranzitivní a obousměrné.
V konečném důsledku tedy každá doména důvěřuje všem ostatním.

Ostatní vztahy důvěry musí být vytvářeny manuálně. Existují celkem čtyři
typy vztahů důvěry, jenž lze vytvořit manuálně:

-   ***Shortcut***. Tento vztah důvěry se používá, pokud je potřeba
    urychlit přístup ke zdrojům nějaké domény z jiné domény ve stejném
    lese. Jak již bylo zmíněno výše, všechny domény v daném lese si
    navzájem důvěřuji, ovšem většinou jen nepřímo díky tranzitivitě
    vytvořených vztahů. Pokud se uživatel z jedné domény chce přihlásit
    na počítač v jiné doméně, musí proběhnout vyhodnocení všech
    tranzitivních vztahů po cestě do této cílové domény, kde se chce
    uživatel přihlásit, a ověřit tedy, že cílová doména důvěřuje výchozí
    doméně. Těchto vztahů ale může být mnoho a ověření tedy trvat příliš
    dlouho. *Shortcut* vztahy důvěry umožňují vytvořit vztah důvěry
    přímo mezi dvěma konkrétními podřízenými doménami. Díky tomu se
    důvěra mezi těmito doménami ověří jednoduše pomocí tohoto vztahu
    důvěry místo vyhodnocování všech vztahů důvěry po cestě z jedné
    domény do druhé. Tyto vztahy důvěry mohou být jednosměrné i
    obousměrné a jsou vždy tranzitivní, lze je tedy použít pro tvorbu
    nových, kratších, cest.

-   ***External***. Tento vztah důvěry se používá, pokud je potřeba
    pracovat s doménami, jenž neleží ve stejném lese. Vytváří vztah
    důvěry mezi dvěma doménami systému Windows z odlišných lesů. Všechny
    tyto vztahy důvěry jsou jednosměrné a nejsou tranzitivní. Pokud je
    vytvořen obousměrný *external* vztah důvěry, jsou místo něj ve
    skutečnosti vytvořeny dva jednosměrné vztahy důvěry, každý v jednom
    směru. V případě, že je vytvořen odchozí *external* vztah důvěry,
    vytvoří **Active Directory** cizí (*foreign*) bezpečnostní objekt
    pro každý bezpečnostní objekt z důvěryhodné domény. Tyto cizí
    bezpečnostní objekty pak mohou být přidány do doménově lokálních
    skupin a ACL seznamů v důvěřující doméně. Pro zvýšení bezpečnosti
    tohoto vztahu důvěry lze využít výběrovou autentizaci a doménovou
    karanténu (povolena ve výchozím nastavení), které budou zmíněny
    dále.

-   ***Realm***. Tento vztah důvěry se používá, pokud je potřeba
    pracovat s bezpečnostními službami založenými na protokolu Kerberos
    v5, jenž běží na jiných systémech, než je systém Windows. Tyto
    vztahy důvěry jsou jednosměrné. Pro vytvoření obousměrného vztahu
    důvěry je možné vytvořit jednosměrné vztahy důvěry v každém z obou
    směrů. Ve výchozím nastavení nejsou tyto vztahy důvěry tranzitivní,
    ale lze je tranzitivními učinit.

-   ***Forest***. Tento vztah důvěry se používá, pokud je potřeba
    spolupráce mezi dvěma organizacemi reprezentovanými pomocí dvou
    odlišných lesů. Vytváří vztah důvěry mezi kořenovými doménami obou
    lesů. Tyto vztahy mohou být jednosměrné i obousměrné a jsou vždy
    tranzitivní. Pokud existuje jednosměrný *forest* vztah důvěry mezi
    dvěma doménami, pak se uživatel z jakékoliv domény v důvěryhodném
    lese může přihlásit k jakémukoliv počítači v důvěřujícím lese (tedy
    k počítači v jakékoliv doméně v důvěřujícím lese). Pokud je tento
    vztah obousměrný, platí to i v opačném směru. *Forest* vztah důvěry
    má ve výchozím nastavení povolenou doménovou karanténu. Tento typ
    vztahů důvěry je vždy tranzitivní, ovšem pouze ve smyslu, že každá
    doména v důvěřujícím lese důvěřuje všem ostatním doménám
    v důvěryhodném lese. *Forest* vztahy důvěry nejsou tranzitivní
    navzájem. Tedy pokud les **A** důvěřuje lesu **B** a dále les **B**
    důvěřuje lesu **C**, pak neplatí, že les **A** důvěřuje lesu **C**.
    Aby bylo možné vytvořit *forest* vztah důvěry, je potřeba mít
    funkční úroveň lesa alespoň Windows Server 2003 a také mít
    odpovídající **DNS** infrastrukturu.

**Zabezpečení vztahů důvěry**

Samotný vztah důvěry sice neumožňuje uživatelům přistupovat ke zdrojům v
důvěřující doméně, ale jeho vytvořením mohou uživatelé z důvěryhodné
domény získat přístup k některým zdrojům v důvěřující doméně. Je to
proto, že velká řada zdrojů je chráněna ACL seznamy, které mohou mít
definovány oprávnění pro skupinu Authenticated Users. Jelikož do této
skupiny patří všichni autentizovaní uživatelé, tedy i autentizovaní
uživatelé z důvěryhodných domén, mohou k těmto zdrojům přistupovat i
tito uživatelé. Kromě toho mohou být samozřejmě uživatelé a globální
skupiny z důvěryhodných domén přímo přidáni do ACL seznamů a také do
doménově lokálních skupin.

I pokud jsou správně nastavena oprávnění pro přístup ke zdrojům v
důvěřující doméně, je zde pořád nebezpečí nepovoleného přístupu. Když se
uživatel autorizuje do důvěřující domény, předkládá autorizační data,
jenž obsahují, mimo jiné, **SID** identifikátory uživatele a skupin,
jichž je daný uživatel členem. Ne všechny tyto identifikátory musí
pocházet (být vytvořeny) z důvěryhodné domény. Např. pokud je uživatel
přesunut z jiné domény, je mu vygenerován nový **SID** identifikátor. V
tomto případě ale uživatel ztrácí přístup ke zdrojům, jenž mají v ACL
seznamech definovány oprávnění pro jeho starý **SID** identifikátor.
Proto lze uchovávat u uživatele historii jeho předchozích **SID**
identifikátorů. Ovšem tímto vzniká nebezpečí podstrčení **SID**
identifikátorů. Administrátor může před migrací uživatele do nové domény
přiřadit tomuto uživateli jako předchozí **SID** identifikátory **SID**
identifikátory důležitých účtů z cílové domény (např. **SID** účtu, jenž
je v Domain Admins) a uživatel tak získá díky historii oprávnění správce
domény. Tento problém řeší doménová karanténa (*domain quarantine*),
jenž zajišťuje ignorování veškerých **SID** identifikátorů, které
nepocházejí z důvěryhodné domény. Doménová karanténa je ve výchozím
nastavení povolena na všech *external* a *forest* vztazích důvěry.

Jak již bylo zmíněno dříve, autentizovaní uživatelé z důvěryhodné domény
jsou automaticky členy Authenticated Users a mohou tedy mít automaticky
přístup k řadě zdrojů v důvěřující doméně. Tato situace nemusí být vždy
žádoucí. V případě přístupu ke zdrojům to lze řešit aplikací deny nebo
odebráním oprávnění skupině Authenticated Users. Tímto postupem ale
nelze omezit přístup ke službám jako je např. přihlašování ke stanicím v
důvěřující doméně. Tento problém řeší výběrová autentizace (*selective
authentication*), jenž umožňuje specifikovat, kteří uživatelé či skupiny
mohou využívat služby na konkrétním počítači. Výběrovou autentizaci lze
povolit u *external* a *forest* vztahů důvěry.

---

# AutomatedLab

```
$labName = 'E12'
New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV

$adminPass = 'root4Lab'

Set-LabinstallationCredential -username root -password $adminPass

Add-LabDomainDefinition -Name testing.local -AdminUser root -AdminPassword $adminPass
Add-LabDomainDefinition -Name child.testing.local -AdminUser root -AdminPassword $adminPass
Add-LabDomainDefinition -Name testing2.local2 -AdminUser root -AdminPassword $adminPass

Add-LabMachineDefinition -Name w2022-dc1  -Memory 4GB -Processors 8  -OperatingSystem 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)' -Roles RootDC -DomainName testing.local
Add-LabMachineDefinition -Name w2022-dc2  -Memory 4GB -Processors 8  -OperatingSystem 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)' -Roles DC -DomainName testing.local

Add-LabMachineDefinition -Name w2022-child-dc1  -Memory 4GB -Processors 8  -OperatingSystem 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)' -Roles FirstChildDC  -DomainName child.testing.local 

Add-LabMachineDefinition -Name w2022-t2-dc1  -Memory 4GB -Processors 8  -OperatingSystem 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)' -Roles RootDC -DomainName testing2.local2

Install-Lab

Show-LabDeploymentSummary -Detailed
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
| **w2022-t2-dc1**         | Internal |

-   V případech, kdy je potřeba přistupovat na externí síť, připojte
    adaptér **LAN1** k přepínači *Default switch*.

---

# Lektorské úkoly {#lektorské-úkoly .IW_nadpis1}

## Lab L01 -- ADDT (Active Directory Domains and Trusts)

> **Cíl cvičení**
>
> Seznámení s ADDT konzolí
>
> **Potřebné virtuální stroje**
>
> **w2022-dc1**
>
> **w2022-dc2**

Otevřete **ADDT** konzoli a projděte ji. Na záložce Trusts ve
vlastnostech domény **testing.local** ukažte automaticky vytvořené
vztahy důvěry, které zajišťují důvěru mezi jednotlivými doménami v daném
lese. Upozorněte, že tyto vztahy jsou jednosměrné, v případě
obousměrných se vytvoří 2 jednosměrné, jeden na každou stranu. Proleťte
vlastnosti nějakého vztahu důvěry. Řekněte k čemu je tranzitivita vztahů
důvěry. Upozorněte na možnost Validate pro ověření funkčnosti daného
vztahu důvěry.

## Lab L02 -- Vytvoření vztahů důvěry

> **Cíl cvičení**
>
> Vytvořit postupně *external* a *forest* vztahy důvěry, ověřit jejich
> funkčnost a seznámit se s jejich odlišnostmi při vyhodnocování důvěry
> mezi doménami
>
> **Potřebné virtuální stroje**
>
> **w2022-dc1**
>
> **w2022-dc2**
>
> **w2022-child-dc1**
>
> **w2022-t2-dc1**
>
> **Další prerekvizity**
>
> Účet uživatele **root** v doméně **testing2.local2**

1.  Přihlaste se na **w2022-dc1** jako **testing\\root**

2.  Přihlaste se na **w2022-t2-dc1** jako **testing2\\root**

3.  Nastavte podmíněné přeposílání DNS dotazů mezi doménami
    **testing.local** a **testing2.local2**

    -   Řekněte, že pro správné fungování vztahů důvěry musí být možné
        překládat DNS jména z druhé domény v daném vztahu důvěry

    -   Zmiňte, že místo podmíněného přeposílání lze použít také třeba
        stub zónu

    a.  Na **w2022-dc1** otevřete **DNS**

        1.  Start → Administrative Tools → **DNS**

    b.  Klikněte pravým na Conditional Forwarders a zvolte New
        Conditional Forwarder...

    c.  Do pole DNS Domain zadejte **testing2.local2** a pod IP
        addresses of the master servers níže vložte IP adresu
        <doplnte IP w2022-t2-dc1> a potvrďte OK

    d.  Opakujte **body 1.a -- 1.c** na **w2022-t2-dc1**, tentokrát pro
        doménu **testing.local** a IP adresu <doplnte IP w2022-dc1>

    e.  Pomocí nástroje nslookup ověřte, že je nyní možné přeložit FQDN
        z opačné domény

4.  Vytvořte nový *external* vztah důvěry tak, aby doména
    **child.testing.local** důvěřovala doméně **testing2.local2**

    a.  Na **w2022-dc1** otevřete **ADDT** (*Active Directory Domains and
        Trusts*)

        1.  Start → Administrative Tools → **Active Directory Domains
            and Trusts**

    b.  Klikněte pravým na doménu **child.testing.local** a zvolte
        Properties

    c.  Přejděte na záložku Trusts a zvolte New Trust...

    d.  V průvodci pokračujte Next \>

    e.  V části Trust Name zadejte do pole Name doménu
        **testing2.local2** a pokračujte Next \>

        -   Upozorněte, že zde se zadává druhá doména, jenž participuje
            ve vytvářeném vztahu důvěry, není to pojmenování vztahu
            důvěry nebo tak něco

    f.  V další části Direction of Trust zvolte One way: outgoing a
        pokračujte Next \>

        -   Řekněte, že s tímto nastavením bude doména
            **child.testing.local** důvěřovat doméně
            **testing2.local2**, ale ne naopak

    g.  V následující části Sides of Trust zvolte Both this domain and
        the specified domain a pak pokračujte Next \>

    h.  V další části User Name and Password zadejte účet uživatele
        **testing2\\root** a pokračujte Next \>

        -   Doménové jméno není nutné uvádět, použije se dříve vybraná
            doména (je zobrazena jako Specified domain)

    i.  V části Outgoing Trust Authentication Level ‒ Local Domain
        zvolte možnost Domain-wide authentication a pokračujte Next \>

    j.  Vytvořte nový vztah důvěry pomocí Next \>

    k.  Pokračujte Next \>

    l.  V části Confirm Outgoing Trust zvolte Yes, confirm the outgoing
        trust a pokračujte Next \>

    m.  Potvrďte pomocí Finish

    n.  Přečtěte si upozornění o zapnutém SID filtering a potvrďte OK

5.  Ověřte, že bodem 2.g došlo i k vytvoření jednosměrného příchozího
    vztahu důvěry v doméně **testing2.local2**

    a.  Na **w2022-t2-dc1** otevřete **ADDT** (*Active Directory Domains
        and Trusts*)

        1.  Start → Administrative Tools → **Active Directory Domains
            and Trusts**

    b.  Klikněte pravým na doménu **testing2.local2** a zvolte
        Properties

    c.  Přejděte na záložku Trusts a ověřte přítomnost
        **child.testing.local** mezi příchozími vztahy důvěry (incoming
        trusts)

6.  Přihlaste se na **w2022-child-dc1** jako **child\\root**

7.  Povolte všem uživatelům přihlásit se na řadiče domény v doméně
    **child.testing.local**

    a.  Na **w2022-child-dc1** otevřete **GPME** (*Group Policy Management
        Editor*)

        1.  Start → Administrative Tools → **Group Policy Management**

    b.  Klikněte pravým na GPO objekt Default Domain Controllers Policy
        a zvolte Edit...

    c.  Vyberte uzel Computer Configuration \\ Policies \\ Windows
        Settings \\ Security Settings \\ Local Policies \\ User Rights
        Assignments

    d.  Klikněte pravým na Allow log on locally a zvolte Properties

    e.  Zaškrtněte Define these policy settings a zvolte Add User or
        Group...

    f.  Zadejte **Everyone** a potvrďte OK

    g.  Potvrďte OK a zavřete Group Policy Management Editor

    h.  Aktualizujte nastavení zásad skupiny příkazem **gpupdate
        /force**

        -   Pozor: Jde jen o zjednodušení úkolu, protože nemáme
            k dispozici klientskou stanici. V praxi toto
            z bezpečnostních důvodů nikdy nedělejte.

8.  Přihlaste se na **w2022-child-dc1** jako uživatel
    **root@testing2.local2**

    -   Přihlášení bude úspěšné, jelikož doména **testing2.local2** je
        důvěryhodnou doménou pro doménu **child.testing.local**

9.  Povolte všem uživatelům přihlásit se na řadiče domény v doméně
    **testing2.local2** provedením postupu z **bodu 5** na **w2022-t2-dc1**

10. Přihlaste se na **w2022-t2-dc1** jako uživatel
    **root@child.testing.local**

    -   Přihlášení nebude úspěšné, jelikož doména
        **child.testing.local** není důvěryhodnou doménou pro doménu
        **testing2.local2**, vytvořený vztah je jednosměrný

11. Povolte všem uživatelům přihlásit se na řadiče domény v doméně
    **testing.local** provedením postupu **bodu 5** na **w2022-dc1**

12. Přihlaste se na **w2022-dc1** jako uživatel
    **root@testing2.local2**

    -   Přihlášení nebude úspěšné, jelikož doména **testing2.local2**
        není důvěryhodnou doménou pro doménu **testing.local**

13. Smažte vytvořený *external* vztah důvěry mezi doménami
    **child.testing.local** a **testing2.local2**

    a.  Na **w2022-dc1** otevřete **ADDT** (*Active Directory Domains and
        Trusts*)

        1.  Start → Administrative Tools → **Active Directory Domains
            and Trusts**

    b.  Klikněte pravým na doménu **child.testing.local** a zvolte
        Properties

    c.  Přejděte na záložku Trusts

    d.  Pod Domains trusted by this domain (outgoing trusts) vyberte v
        seznamu **testing2.local2** zvolte Remove

    e.  Vyberte Yes, remove the trust from both the local domain and the
        other domain a použijte účet uživatele
        **testing2\\root**

    f.  Potvrďte odebrání pomocí Yes

14. Vytvořte *forest* vztah důvěry tak, aby kořenová doména lesa
    **testing.local** důvěřovala kořenové doméně lesa
    **testing2.local2**

    a.  Na **w2022-dc1** otevřete **ADDT** (*Active Directory Domains and
        Trusts*)

        1.  Start → Administrative Tools → **Active Directory Domains
            and Trusts**

    b.  Klikněte pravým na doménu **testing.local** a zvolte Properties

    c.  Přejděte na záložku Trusts a zvolte New Trust...

    d.  V průvodci pokračujte Next \>

    e.  V části Trust Name zadejte do pole Name doménu
        **testing2.local2** a pokračujte Next \>

    f.  V další části Trust Type vyberte Forest Trust a pokračujte Next
        \>

        -   Připomeňte, že *forest* vztah důvěry je vždy mezi kořenovými
            doménami dvou lesů, takže v předchozím případě (u domény
            **child.testing.local**) byl automaticky vybrán typ
            *external*, jelikož forest by stejně nešel vytvořit

    g.  V následující části Direction of Trust zvolte One way: outgoing
        a pokračujte Next \>

    h.  V části Sides of Trust ponechte This domain only a pokračujte
        Next \>

    i.  V další části Outgoing Trust Authentication Level zvolte
        Forest-wide authentication a pokračujte Next \>

    j.  V následující části Trust Password použijte heslo **aaaAAA111**
        a pokračujte Next \>

        -   Řekněte, že toto heslo je potřeba pro spárování
            odpovídajících *incoming* a *outgoing* vztahů důvěry, pokud
            jsou vytvářeny samostatně v obou participujících doménách

    k.  Vytvořte nový vztah důvěry pomocí Next \>

    l.  Pokračujete Next \>

    m.  V části Confirm Outgoing Trust zvolte No, do not confirm the
        outgoing trust a pokračujte Next \>

    n.  Potvrďte pomocí Finish

15. Dokončete vytvoření forest vztahu důvěry v doméně
    **testing2.local2**

    a.  Na **w2022-t2-dc1** otevřete **ADDT** (*Active Directory Domains
        and Trusts*)

        1.  Start → Administrative Tools → **Active Directory Domains
            and Trusts**

    b.  Klikněte pravým na doménu **testing2.local2** a zvolte
        Properties

    c.  Přejděte na záložku Trusts a zvolte New Trust...

    d.  V průvodci pokračujte Next \>

    e.  V části Trust Name zadejte do pole Name doménu **testing.local**
        a pokračujte Next \>

    f.  V další části Trust Type vyberte Forest Trust a pokračujte Next
        \>

    g.  V následující části Direction of Trust zvolte One way: incoming
        a pokračujte Next \>

    h.  V části Sides of Trust ponechte This domain only a pokračujte
        Next \>

    i.  V další části Trust Password zadejte heslo **aaaAAA111** a
        pokračujte Next \>

    j.  Vytvořte nový vztah důvěry pomocí Next \>

    k.  Pokračujte Next \>

    l.  V části Confirm Incoming Trust zvolte Yes, confirm the incoming
        trust a zadejte účet uživatele **testing\\root** a pokračujte Next \>

    m.  Potvrďte pomocí Finish

16. Přihlaste se na **w2022-dc1** jako uživatel
    **root@testing2.local2**

    -   Přihlášení bude úspěšné, jelikož doména **testing2.local2** je
        důvěryhodnou doménou pro doménu **testing.local**

    ```{=html}
    <!-- -->
    ```
    -   V případě chyby The name or security ID (SID) of the domain
        specified is inconsistent with the trust information for that
        domain zkuste chvíli počkat a případně forest trust zrušit a
        znovu nastavit

17. Přihlaste se na **w2022-t2-dc1** jako uživatel
    **root@testing.local**

    -   Přihlášení nebude úspěšné, jelikož doména **testing.local** není
        důvěryhodnou doménou pro doménu **testing2.local2**, vytvořený
        vztah je jednosměrný

18. Přihlaste se na **w2022-child-dc1** jako uživatel
    **root@testing2.local2**

    -   Přihlášení bude úspěšné, jelikož doména **testing2.local2** je
        důvěryhodnou doménou pro doménu **testing.local**, doména
        **child.testing.local** důvěřuje své nadřízené (*parent*) doméně
        **testing.local**, doména **testing.local** zase důvěřuje
        **testing2.local2** doméně, oba tyto vztahy důvěry jsou
        tranzitivní, takže také doména **child.testing.local** důvěřuje
        doméně **testing2.local2**

# Studentské úkoly {#studentské-úkoly .IW_nadpis1}

Lab S01 -- Zabezpečení vztahů důvěry

> **Cíl cvičení**
>
> Nastavit a ověřit výběrovou autentizaci, vypnout a zapnout doménovou
> karanténu
>
> **Potřebné virtuální stroje**
>
> **w2022-dc1** (D+R+C w2022-dc1)
>
> **w2022-child-dc1** (D+R+C w2022-child-dc1)
>
> **w2022-t2-dc1** (w2022-t2-dc1)
>
> **Další prerekvizity**
>
> Dokončený úkol **Lab L02**

1.  Přihlaste se na **w2022-dc1** jako **testing\\root**

2.  Povolte výběrovou autentizaci pro *forest* vztah důvěry mezi
    **testing.local** a **testing2.local2**

    a.  Na **w2022-dc1** otevřete **ADDT** (*Active Directory Domains and
        Trusts*)

        1.  Start → Administrative Tools → **Active Directory Domains
            and Trusts**

    b.  Klikněte pravým na doménu **testing.local** a zvolte Properties

    c.  Přejděte na záložku Trusts

    d.  Pod Domains trusted by this domain (outgoing trusts) vyberte v
        seznamu **testing2.local2** zvolte Properties...

    e.  Přejděte na záložku Authentication a vyberte Selective
        authentication

    f.  Potvrďte dvakrát OK

3.  Přihlaste se na **w2022-dc1** jako uživatel
    **root@testing2.local2**

    -   Přihlášení nebude úspěšné, jelikož po povolení selektivní
        *autentizace* nelze využívat žádné služby počítačů v důvěřující
        doméně

4.  Přihlaste se na **w2022-dc1** jako **testing\\root**

5.  Povolte využívání služeb **w2022-dc1**

    a.  Na **w2022-dc1** otevřete **ADUC** (*Active Directory Users and
        Computers*)

        1.  Start → Administrative Tools → **Active Directory Users and
            Computers**

    b.  Povolte pokročilé možnosti zobrazení

        1.  V menu konzole vyberte View a zvolte Advanced Features

    c.  Vyberte organizační jednotku Domain Controllers

    d.  Klikněte pravým na účet počítače **w2022-dc1** a zvolte
        Properties

    e.  Přejděte na záložku Security, pak v seznamu pod Group or user
        names vyberte skupinu Authenticated Users a zaškrtněte Allow u
        Allowed to authenticate

    f.  Potvrďte OK

6.  Přihlaste se na **w2022-dc1** jako uživatel
    **root@testing2.local2**

    -   Přihlášení již bude úspěšné, jelikož všichni uživatelé z
        důvěryhodných domén jsou členy skupiny Authenticated Users a ta
        má nyní oprávnění využívat služby tohoto počítače

7.  Přihlaste se na **w2022-dc1** jako **testing\\root**

8.  Vypněte doménovou karanténu pro *forest* vztah důvěry mezi
    **testing.local** a **testing2.local2**

    a.  Na **w2022-dc1** spusťte jako administrátor příkazový řádek

    b.  Spusťte příkaz **netdom trust testing.local /d:testing2.local2
        /quarantine:no /userD:root@testing2.local2
        /passwordD:aaa**

9.  Zapněte doménovou karanténu pro *forest* vztah důvěry mezi
    **testing.local** a **testing2.local2**

    a.  Na **w2022-dc1** spusťte jako administrátor příkazový řádek

    b.  Spusťte příkaz **netdom trust testing.local /d:testing2.local2
        /quarantine:yes** **/userD:root@testing2.local2
        /passwordD:aaa**

# Bodované úkoly {#bodované-úkoly .IW_nadpis1}

Úkol 1

-   Zajistěte, aby se uživatelé z **testing.local** mohli přihlásit na
    počítače v doméně **testing2.local2**, a naopak uživatelé z
    **testing2.local2** zase na počítače v doméně **testing.local**,
    přihlašování mezi jinými dvojicemi domén napříč lesy nesmí být
    možné.


-   Na **w2022-dc1** zkontrolovat *incoming* a *outgoing* vztahy důvěry
    do **testing2.local2** a také, že nejsou tranzitivní.

[^1]: Kořenová doména lesa je první doména vytvořená v daném lese
    **Active Directory**
