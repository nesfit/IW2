- [Active Directory - Zásady skupiny (uložení, šablony)](#active-directory---zásady-skupiny-uložení-šablony)
  - [Uložení GPO objektů](#uložení-gpo-objektů)
  - [Replikace GPO objektů](#replikace-gpo-objektů)
  - [Šablony pro správu](#šablony-pro-správu)
  - [Instalace softwaru pomocí zásad skupiny](#instalace-softwaru-pomocí-zásad-skupiny)
- [AutomatedLab](#automatedlab)
- [Společné úkoly](#společné-úkoly)
  - [Lab LS00 -- konfigurace virtuálních stanic](#lab-ls00----konfigurace-virtuálních-stanic)
- [Studentské úkoly](#studentské-úkoly)
  - [Lab S01 -- Bezpečnostní filtry](#lab-s01----bezpečnostní-filtry)
  - [Lab S02 -- Šablony pro správu](#lab-s02----šablony-pro-správu)
  - [Lab S03 -- Publikace aplikací pomocí GPO objektů](#lab-s03----publikace-aplikací-pomocí-gpo-objektů)
  - [Lab S04 -- Instalace aplikací pomocí GPO objektů a WMI filtrů](#lab-s04----instalace-aplikací-pomocí-gpo-objektů-a-wmi-filtrů)
- [Bodované úkoly](#bodované-úkoly)

# Active Directory - Zásady skupiny (uložení, šablony)

## Uložení GPO objektů

Nastavení zásad skupiny jsou v **Active Directory** reprezentována jako
**GPO** objekty, tyto objekty se ovšem skládají ze dvou komponent ‒
kontejner zásad skupiny (**GPC**, *Group Policy Container*) a šablona
zásad skupiny (**GPT**, *Group Policy Template*). **GPC** kontejner je
konkrétní objekt **Active Directory**, jenž je uložen v kontejneru
Objekty zásad skupiny (*Group Policy Objects*). Stejně jako ostatní
objekty **Active Directory** obsahuje globální unikátní identifikátor
(**GUID**) a další atributy. Tento objekt ovšem neobsahuje žádná
nastavení zásad skupiny. Tato nastavení jsou obsažena v **GPT** šabloně,
což je kolekce souborů uložených v kořenovém adresáři **SYSVOL** na
každém řadiči domény, přesněji v adresáři
***\<systém\>*\\SYSVOL\\Domain\\Policies\\*\<gpc-guid\>***, kde
*\<gpc-guid\>* je **GUID** identifikátor **GPC** kontejneru a
*\<systém\>* je kořenový adresář systému Windows. V případě, že dojde ke
změně nastavení zásad v **GPO** objektu, jsou tyto změny uloženy do
**GPT** šablony na serveru, kde byl daný **GPO** objekt modifikován a
replikovány s celým adresářem **SYSVOL** na ostatní řadiče domény.

Ve výchozím nastavení aplikují **CSE** rozšíření nastavení zásad v
**GPO** objektu pouze pokud byl tento objekt změněn. Zjištění, zda byl
daný **GPO** objekt změněn, se provádí na základě čísla verze tohoto
objektu. Toto číslo je inkrementováno pokaždé, když dojde ke změně
nastavení nějaké zásady obsažené v daném **GPO** objektu, a je uloženo
jako atribut **GPC** kontejneru a také v souboru **GPT.ini** v **GPT**
adresáři. Klient si pamatuje číslo verze každého **GPO** objektu, jenž
aplikoval naposledy a při aktualizaci nejprve ověří, zda byl daný
**GPO** objekt změněn a je potřeba ho tedy aplikovat.

## Replikace GPO objektů

Replikace **GPO** objektů mezi jednotlivými řadiči domény je
komplikovanější, jelikož každá z obou komponent **GPO** objektu je
replikována odlišným způsobem. Replikaci **GPC** kontejnerů zajišťuje
**DRA** (*Directory Replication Agent*) s využitím topologie generované
**KCC** (*Knowledge Consistency Checker*). Výsledkem je, že **GPC**
kontejnery jsou replikovány v rámci daného místa (*site*) během několika
sekund a mezi místy podle nastavení mezimístní (*intersite*) replikace.

Replikace **GPT** šablon je realizována jednou ze dvou technologií. Buď
pomocí služby replikace souborů (**FRS**, *File Replication Service*),
která je podporována i staršími systémy jako Windows 2000 nebo Windows
Server 2003, ale ve Windows Server 2019 již není k dispozici. Nebo lze
využít novější a robustnější replikaci distribuovaného souborového
systému (**DFS-R**, *Distributed File System Replication*), jenž je k
dispozici od verze systému Windows Server 2008.

Jelikož jsou **GPC** kontejnery a **GPT** šablony replikovány odděleně,
může nastat situace, kdy nejsou tyto komponenty synchronizovány, tedy
došlo k replikaci pouze jedné z těchto částí. Zde mohou nastat dvě
situace. Buď dojde pouze k replikaci **GPC** kontejneru, což je častější
případ. V tomto případě klient při obdržení uspořádaného seznamu **GPO**
objektů zjistí, že došlo ke změně daného **GPC** kontejneru a pokusí se
získat odpovídající **GPT** šablonu. Tato šablona ovšem bude obsahovat
jiné číslo verze a dojde k chybě, kterou klient zaznamená do protokolu
událostí. Nebo se dříve replikuje **GPT** šablona. Zde klient vůbec
nezjistí, že došlo k nějaké změně, dokud se nereplikuje také
odpovídající **GPC** kontejner. Tyto nekonzistence mezi **GPC**
kontejnery a **GPT** šablonami lze jednoduše identifikovat pomocí
nástroje **Gpotool.exe**[^1] (*Group Policy Verification Tool*).

## Šablony pro správu

Zásady situované pod uzlem Šablony pro správu (*Administrative
Templates*) slouží k modifikaci registru. V případě, že spadají pod uzel
Konfigurace počítače (*Computer Configuration*), tak modifikují hodnoty
klíčů registru ve větvi HKEY_LOCAL_MACHINE (HKLM). Pokud náleží pod uzel
Konfigurace uživatele (*User Configuration*), tak modifikují hodnoty
klíčů registru ve větvi HKEY_CURRENT_USER (HKCU). Tyto zásady jsou
vytvářeny na základě šablon pro správu.

Šablona pro správu (*administrative template*) je normální textový
soubor, jenž obsahuje definice jednotlivých zásad. Pro každou zásadu
obsahuje hlavně informace o klíči registru, který tato zásada
modifikuje, a podrobné informace, ze kterých se generuje uživatelské
rozhraní pro nastavení této zásady. Tyto informace zahrnují např. název
zásady, třídu (zásada pro počítač nebo uživatele), popis, seznam
podporovaných verzí systému, ale hlavně informace definující jak se mají
změnit hodnoty cílového klíče registru na základě nastavení této zásady.

Šablony pro správu umožňují přidávat nové zásady, jež mohou modifikovat
klíče registru, čehož lze s výhodou využít pro centralizovanou
konfiguraci aplikací třetích stran. Stačí pouze vytvořit novou šablonu
pro správu a přidat ji k uzlu Šablony pro správu. Zásady obsažené v této
šabloně pak budou součástí všech **GPO** objektů. Při vytváření nových
šablon pro správu lze vycházet z předdefinovaných, nebo dříve
definovaných, šablon. Tyto šablony se označují jako tzv. *Starter*
**GPO** objekty.

V předchozích verzích systému Windows (před Windows Vista) byly šablony
pro správu **ADM** soubory (soubory s příponou *.adm*). Tyto soubory
měly ovšem několik nevýhod. Veškerá lokalizace se musela provádět v
rámci **ADM** souboru, tedy pro každý jazyk musel existovat jeden ADM
soubor a při úpravách se musely modifikovat všechny tyto soubory. Dalším
problémem bylo uložení. **ADM** soubory byly součástí **GPT** šablon,
tedy každý **GPO** objekt, jenž používal danou šablonu, obsahoval
v **GPT** šabloně jednu kopii **ADM** souboru této šablony. Kromě
zbytečné replikace stejných dat to znamenalo také problémy při úpravách
**ADM** souboru šablony, kdy musely být změněny veškeré kopie.

Od systémů Windows Vista a Windows Server 2008 jsou šablony pro správu
dvojice XML souborů, jeden pro definici jednotlivých zásad (**ADMX**
soubor, soubor s příponou *.admx*) a druhý pro definici uživatelského
rozhraní v různých jazycích (**ADML** soubor, soubor s příponou
*.adml*). **ADML** soubory pouze mapují speciální identifikátory na
odpovídající prvek rozhraní nebo text v konkrétním jazyce. **ADMX**
soubory pak používají místo prvků a textů jen tyto identifikátory. Při
editaci zásady definované v **ADMX** souboru se pak jen vyhledá
odpovídající **ADML** soubor, jenž bude použit pro generování
uživatelského rozhraní.

V případě použití **ADMX**/**ADML** šablon pro správu obsahuje **GPO**
objekt pouze ty informace, jenž klient potřebuje pro zpracování daného
**GPO** objektu. Při editaci **GPO** objektu pak editor zásad skupiny
(**GPME**, *Group Policy Management Editor*) načte **ADMX** a **ADML**
soubory z lokálního počítače. Lze ale vytvořit jakési centrální úložiště
(*central store*) pro tyto šablony. Centrální úložiště je speciální
adresář v kořenovém adresáři **SYSVOL**, kde jsou uloženy veškeré
šablony pro správu. Pokud tento adresář existuje, **GPME** bude načítat
všechny šablony z tohoto adresáře, místo z lokálního počítače.

Centrální úložiště se vytvoří jednoduše. Stačí pouze vytvořit adresář
**PolicyDefinitions** v adresáři **\\\\*\<FQDN
domény\>*\\SYSVOL\\*\<FQDN domény\>*\\Policies** a pak do něj přesunout
šablony pro správu uložené v adresáři
***\<systém\>*\\PolicyDefinitions**, kde *\<systém\>* je kořenový
adresář systému Windows na lokálním počítači.

## Instalace softwaru pomocí zásad skupiny

Instalace softwaru pomocí zásad skupiny (**GPSI**, *Group Policy
Software Instalation*) se používá pro zajištění přístupu uživatelů k
aplikacím, které potřebují, ať jsou přihlášeni na jakémkoliv počítači.
Tyto aplikace mohou být centrálně aktualizovány, spravovány nebo
odebírány. Tuto funkcionalitu poskytuje jedno z **CSE** rozšíření,
rozšíření instalací softwaru (*Software Instalation Extension*).

**GPSI** využívá **Instalační službu systému Windows** (*Windows
Installer service*) pro instalaci, aktualizaci a odstraňování softwaru.
Tato služba pracuje s instalačními balíky Windows (*Windows Installer
package*), což jsou soubory s příponou *.msi*, které zachycují stav
nainstalované aplikace. Tento balík obsahuje informace potřebné pro
instalaci a odebrání dané aplikace. Instalační balíky Windows lze také
upravovat jedním z následujících způsobů:

-   **Transformační soubory** (*Transform files*). Soubory s příponou
    *.mst*, které umožňují upravovat proces instalace dané aplikace.
    Tyto soubory se používají hlavně pro konfiguraci instalátoru
    aplikace tak, aby mohla být provedena bez zásahu uživatele.

-   **Záplatové soubory** (*Patch files*). Soubory s příponou *.msp*,
    které umožňují aktualizovat existující *.msi* soubory. Tyto soubory
    se používají hlavně pro aplikaci aktualizací a oprav. Obsahují
    informace potřebné pro aplikaci aktualizovaných souborů a klíčů
    registrů.

**GPSI** poskytuje několik možností, jak provést instalaci aplikace. Buď
lze aplikaci přiřadit uživateli či počítači, nebo publikovat uživateli:

-   **Přiřazení aplikace** (*assigning*). Při přiřazení aplikace
    uživateli jsou na počítači, kde je uživatel přihlášen, zapsána
    nastavení této aplikace do lokálního registru (včetně přípon souborů
    dané aplikace) a přidáni zástupci na plochu nebo do nabídky Start.
    Aplikace je nainstalována teprve tehdy, když ji uživatel spustí nebo
    otevře soubor, s jehož příponou je aplikace asociována. Pokud je
    aplikace přiřazena počítači, je nainstalována při startu daného
    počítače.

-   **Publikování aplikace** (*publishing*). Při publikování aplikace
    uživateli je aplikace pouze k dispozici pro instalaci v Přidat nebo
    odebrat programy (*Add Or Remove Programs*) ve starších systémech,
    jako Windows XP, nebo v Programy a funkce (*Programs And Features*)
    na novějších systémech, od Windows Vista a Windows Server 2008.
    Instalace je také spuštěna, pokud uživatel otevře soubor, jenž je
    asociován s danou aplikací.

**CSE** rozšíření mohou automaticky ověřovat rychlost linky, kterou jsou
spojeny s řadičem domény. Rozšíření instalací softwaru, které využívá
**GPSI**, je jedním z nich. Za pomalou linku (*slow link*) se bere ve
výchozím nastavení linka s rychlostí nižší než 500 kbps. **GPSI**
standardně neprovádí instalace softwaru přes pomalou linku. Toto chování
lze změnit v zásadách skupiny, stejně jako práh pro rozhodování, zda je
daná linka pokládána za pomalou.

---

# AutomatedLab

```
$labName = 'E08'
New-LabDefinition -Name $labName -DefaultVirtualizationEngine HyperV -VmPath "E:\AutomatedLab-VMs"

$adminPass = 'root4Lab'

set-labinstallationcredential -username root -password $adminPass
add-labdomaindefinition -Name testing.local -AdminUser root -AdminPassword $adminPass

Add-LabMachineDefinition -Name w2022-dc1  -Memory 4GB -Processors 8  -OperatingSystem 'Windows Server 2022 Datacenter Evaluation (Desktop Experience)' -Roles RootDC -DomainName testing.local
Add-LabMachineDefinition -Name w11-domain -Memory 4GB -Processors 8  -OperatingSystem 'Windows 11 Pro' -DomainName testing.local


Install-Lab

Invoke-LabCommand -ActivityName 'Create Users' -ScriptBlock {
    $password = 'root4Lab' | ConvertTo-SecureString -AsPlainText -Force

    New-ADUser -Name student -SamAccountName Student -AccountPassword $password -Enabled $true
    
    New-ADOrganizationalUnit -Name brno -path "DC=testing,DC=local" 
    New-ADOrganizationalUnit -Name brnopcs -path "DC=testing,DC=local" 

    $Simpsons = New-ADGroup -Name "Simpsons" -SamAccountName Simpsons -GroupCategory Security -GroupScope Global -DisplayName "Simpsons" -Path "OU=brno,DC=testing,DC=local" -Description "Members of this group are Simpsons"

    $Homer = New-ADUser -Name Homer -path "OU=brno,DC=testing,DC=local"  -AccountPassword $password -Enabled $true

    Add-ADGroupMember -Identity $Simpsons -Members $Homer

    Move-ADObject "CN=w11-domain,CN=computers,DC=testing,DC=local" -TargetPath "OU=brnopcs,DC=testing,DC=local"

    # Lab evaluation prep
    Set-GPRegistryValue -Name "Enterprise GPO" -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "NoAutoUpdate" -Type DWORD -Value 0
    Set-GPRegistryValue -Name "Enterprise GPO" -Key "HKLM\Software\Policies\Microsoft\Windows\WindowsUpdate\AU" -ValueName "AUOptions" -Type DWORD -Value 2

    New-GPO "DC GPO"
    Set-GPRegistryValue -Name "DC GPO" -Key "HKCU\Software\Microsoft\Windows\CurrentVersion\Policies\System" -ValueName "DisableTaskMgr" -Type DWORD -Value 1

    $usersContainer = [ADSI]"LDAP://CN=Users,DC=testing,DC=local"
    $iw2testUser = $usersContainer.Create("user", "CN=iw2test")
    $iw2testUser.Put("sAMAccountName", "iw2test") 
    $iw2testUser.SetInfo()
    $iw2testUser.SetPassword("aaaAAA111")
    $iw2testUser.SetInfo()
    $iw2testUser.InvokeSet("AccountDisabled", $false)
    $iw2testUser.SetInfo()

    $soGroup = [ADSI]"LDAP://CN=Server Operators,CN=Builtin,DC=testing,DC=local" 
    $soGroup.Member.Add("CN=iw2test,CN=Users,DC=testing,DC=local") 
    $soGroup.CommitChanges()
    
} -ComputerName w2022-dc1

Invoke-LabCommand -ActivityName 'Add Remote Desktop Users' -ScriptBlock {

    Add-LocalGroupMember -Group "Remote Desktop Users" -Member Homer

} -ComputerName w11-domain


Show-LabDeploymentSummary
```

---


# Společné úkoly

-   Upravte nastavení RAM a CPU dle použitých PC

## Lab LS00 -- konfigurace virtuálních stanic

Připojte sítové adaptéry stanic k následujícím virtuálním přepínačům:

| **Adaptér (MAC suffix)** | **LAN**  |
| ------------------------ | -------- |
| **w10_x86**              | Internal |
| **w11-domain**           | Internal |
| **w2022-dc**             | Internal |

-   v případech, kdy je potřeba přistupovat na externí síť, připojte
    adaptér **LAN** k přepínači *Default switch*.

# Studentské úkoly

## Lab S01 -- Bezpečnostní filtry

> **Cíl cvičení**
>
> Definovat rozsah GPO objektu na základě příslušnosti uživatelů do
> skupin
>
> **Potřebné virtuální stroje**
>
> **w2022-dc**
>
> **w11-domain**
>
> **Další prerekvizity**
>
> Účet uživatele **student** v kontejneru Users v doméně
> **testing.local**, který nepatří do skupiny **Simpsons**, účet
> uživatele **Homer** v kontejneru Users v doméně **testing.local**,
> jenž náleží do skupiny **Simpsons**

Potřeba zkontrolovat a případně doplnit

1.  Na **w2022-dc** se přihlaste jako uživatel **root** do
    domény **testing.local**

2.  Otevřete **GPME** (*Group Policy Management Editor*)

    a.  Start → Administrative Tools → **Group Policy Management**

3.  Vytvořte nový GPO objekt **Simpsons GPO** a rovnou ho připojte k
    doméně **testing.local**

    a.  Klikněte pravým na doménu **testing.local** a zvolte Create a
        GPO in this domain, and Link it here...

    b.  Jako název (Name) zvolte **Simpsons GPO** a u Source Starter GPO
        ponechte (**none**)

    c.  Potvrďte OK

4.  V GPO objektu **Simpsons GPO** zakažte změnu barvy oken (Color)

    a.  Klikněte pravým na GPO objekt **Simpsons GPO** a zvolte Edit...

    b.  Vyberte uzel User Configuration \\ Policies \\ Administrative
        Templates \\ Control Panel \\ Personalization

    c.  Klikněte pravým na zásadu Prevent changing color and appearance
        a zvolte Edit

    d.  Přepněte nastavení na Enabled a potvrďte OK

5.  Nastavte rozsah GPO objektu **Simpsons GPO** pouze na uživatele
    skupiny **Simpsons**

    a.  Vyberte GPO objekt **Simpsons GPO**

    b.  Na záložce Scope v části Security Filtering zvolte Add...

    c.  Do Enter the object name to select zadejte **Simpsons** a ověřte
        pomocí Check Names

    d.  Potvrďte OK

    e.  Vyberte skupinu Authenticated Users, zvolte Remove a potvrďte OK

6.  Vytvořte nový GPO objekt **NonSimpsons GPO** podle postupu z **bodu
    2**

7.  V GPO objektu **NonSimpsons GPO** zakažte změnu motivů (Themes)

    a.  Klikněte pravým na GPO objekt **NonSimpsons GPO** a zvolte
        Edit...

    b.  Vyberte uzel User Configuration \\ Policies \\ Administrative
        Templates \\ Control Panel \\ Personalization

    c.  Klikněte pravým na zásadu Prevent changing theme a zvolte Edit

    d.  Přepněte nastavení na Enabled a potvrďte OK

8.  Nastavte rozsah GPO objektu **NonSimpsons GPO** na všechny
    uživatele, jenž nejsou členy skupiny **Simpsons**

    a.  Vyberte GPO objekt **NonSimpsons GPO**

    b.  Na záložce Delegation zvolte Advanced...

    c.  Na záložce Security pod Group or user names zvolte Add...

    d.  Do Enter the object name to select zadejte **Simpsons** a ověřte
        pomocí Check Names

    e.  Potvrďte OK

    f.  Zaškrtněte Deny u Apply group policy

    -   Volitelně můžete také odškrtnout Allow u Read, ale to v
            našem případě nebude dostatečné, protože je zaškrtnuto Allow
            Read u Authenticated Users.

    g.  Potvrďte OK a následně zvolte Yes

9.  Přihlaste se na **w11-domain** jako uživatel **homer**

10. Spusťte příkaz `gpupdate /force`, uživatele odhlaste a přihlaste
    zpět

11. Ověřte, že uživatel **homer** nemůže měnit barvy, ale témata ano

    -   Settings \\ Personalization \\ Colors

    -   Settings \\ Personalization \\ Themes (Apply a theme)

    -   Pokud by nezafungovalo, vraťte Authenticated Users na záložce
        Scope objektu **Simpsons GPO** a následně na záložce Delegation
        zvolte Advanced... a skupině Authenticated Users odeberte Allow
        u Apply group policy (tj. ponechte pouze Read)

12. Přihlaste se na **w11-domain** jako uživatel **student** a ověřte,
    že pod tímto uživatelem nelze měnit motivy, ale barvy měnit lze

## Lab S02 -- Šablony pro správu

> **Cíl cvičení**
>
> Použít šablony pro správu MS Office
>
> **Potřebné virtuální stroje**
>
> **w2022-dc**
>
> **w11-domain**
>
> **Další prerekvizity**
>
> Obstarejte si archiv **admintemplates_x86_4822-1000_en-us.exe** obsahující šablony
> pro správu MS Office 2016 a 2019. Použijte Google / Bing... :)

1.  Přihlaste se na **w2022-dc** jako uživatel **root**

2.  Otevřete **GPME** (*Group Policy Management Editor*)

    a.  Start → Administrative Tools → **Group Policy Management**

3.  Vytvořte nový GPO objekt **Office GPO** a rovnou ho připojte k
    doméně **testing.local**

    a.  Klikněte pravým na doménu **testing.local** a zvolte Create a
        GPO in this domain, and Link it here...

    b.  Jako název (Name) zvolte **Office GPO** a u Source Starter GPO
        ponechte (**none**)

    c.  Potvrďte OK

4.  Ověřte, že v **Office GPO** nejsou k dispozici nastavení MS Office

    a.  Klikněte pravým na GPO objekt **Office GPO** a zvolte Edit...

    b.  Vyberte uzel User Configuration \\ Policies \\ Administrative
        Templates: Policy definition (ADMX files) retrieved from the
        local computer

    c.  Ukončete GPME

5.  Zkopírujte archiv **admintemplates_x86_4822-1000_en-us.exe** na
    **w2022-dc**, rozbalte jej (spusťte, odsouhlaste licenční podmínky a
    vyberte cílovou složku, např. C:\\Office2016admx)

6.  Prozkoumejte obsah získaných admx souborů ve složce **admx** a
    lokalizačních adml souborů ve složce **admx\\*\<jazyk\>***

    -   jedná se o soubory ve formátu xml, otevřete je v libovolném
        textovém editoru

    -   všimněte si souboru office2016grouppolicyandoctsettings.xlsx

7.  Přejděte do **\\\\testing.local*\\*SYSVOL\\testing.local\\Policies**
    a vytvořte složku **PolicyDefinitions**

8.  Do složky **PolicyDefinitions** zkopírujte obsah složky **admx**
    (můžete zvolit i jednotlivé admx a adml soubory zvoleného jazyka - v
    našem případě en-us)

9.  Otevřete **GPME** (*Group Policy Management Editor*)

    a.  Start → Administrative Tools → **Group Policy Management**

10. Ověřte, že v **Office GPO** jsou k dispozici nastavení MS Office

    a.  Klikněte pravým na GPO objekt **Office GPO** a zvolte Edit...

    b.  Vyberte uzel User Configuration \\ Policies \\ Administrative
        Templates: Policy Definitions (ADMX files) retrieved from the
        central store.

    -   Všimněte si, že došlo ke změně na z local computer na
            central store a jsou zobrazena pouze nastavení MS Office.
            Původní nastavení Windows doplníte nakopírováním
            odpovídajících admx a adml souborů ze složky
            *\<systém\>*\\PolicyDefinitions, případně lze stáhnout
            šablony pro správu z webu MS pro konkrétní klientské verze
            Windows[^2].

    c.  Ukončete GPME

## Lab S03 -- Publikace aplikací pomocí GPO objektů

> **Cíl cvičení**
>
> Zpřístupnit aplikaci uživatelům v podnikové síti pro případnou
> instalaci
>
> **Potřebné virtuální stroje**
>
> **w2022-dc**
>
> **w11-domain**
>
> **Další prerekvizity**
>
> Účet uživatele **homer** v organizační jednotce **brno** v doméně
> **testing.local**, GPO objekt **Brno GPO** připojený k organizační
> jednotce **brno** v doméně **testing.local**, sdílený adresář
> **share** na **w2022-dc** obsahující soubor **7z920.msi**.

Potřeba zkontrolovat a případně doplnit

1.  Přihlaste se na **w2022-dc** jako uživatel **root**

2.  Otevřete **GPME** (*Group Policy Management Editor*)

    a.  Start → Administrative Tools → **Group Policy Management**

3.  V GPO objektu **Brno GPO** publikujte (*publish*) aplikaci
    uživatelům

    a.  Klikněte pravým na GPO objekt **Brno GPO** a zvolte Edit...

    b.  Vyberte uzel User Configuration \\ Policies \\ Software Settings

    c.  Klikněte pravým na Software Instalation a zvolte New →
        Package...

    d.  Vyberte instalační soubor **\\\\w2022-dc\\share\\7z920.msi**

    -   Zadaná cesta musí být síťovou cestou k instalačnímu souboru
            aplikace, jinak nebude pro klienta možné lokalizovat na síti
            tento instalační soubor a instalace selže

    e.  U Select deployment method zvolte **Advanced**

    f.  Na záložce Deployment zvolte u Deployment type typ **Published**
        a níže pod Deployment options zaškrtněte nastavení **Uninstall
        this application when it falls out of the scope of management**

    g.  Potvrďte OK

4.  Na **w11-domain** se přihlaste jako uživatel **homer** a
    nainstalujte aplikaci

    a.  spusťte `gpupdate /force`

    b.  Otevřete Programs and Features

    1.  Control Panel → Programs and Features

        -   Alternativně Settings → Apps → Apps & Features --
                Programs and Features pod Related settings

    c.  V panelu vlevo zvolte Install a program from the network

    d.  V seznamu vyberte **7-Zip 9.20** a zvolte Install

    e.  Ponechte výchozí nastavení, přijměte licenční podmínky a
        nainstalujte aplikaci

    f.  Spusťte **7-Zip File Manager** a ověřte, že aplikace byla
        opravdu nainstalována

5.  Přesuňte uživatele **homer** do kontejneru Users

6.  Na **w11-domain** spusťte `gpupdate /force`, odhlaste a znovu
    přihlaste uživatele **homer** a ověřte, že aplikace byla odstraněna

## Lab S04 -- Instalace aplikací pomocí GPO objektů a WMI filtrů

> **Cíl cvičení**
>
> Centrálně nasadit 32-bit a 64-bit verze aplikace pomocí GPO objektů a
> WMI filtrů
>
> **Potřebné virtuální stroje**
>
> **w2022-dc**
>
> **w10_x86**
>
> **w11-domain**
>
> **Další prerekvizity**
>
> Účet uživatele **homer** v doméně **testing.local**, sdílený adresář
> **share** na **w2022-dc** obsahující soubory **7z920.msi** a
> **7z920-x64.msi** (**7z920.msi** i **7z920-x64.msi** jsou k dispozici
> lokálně na serveru **file** v adresáři
> **\\\\file.nepal.local\\data\\kurzy pro FIT a FEKT\\IW2\\cv08**)

Potřeba zkontrolovat a případně doplnit

1.  Přihlaste se na **w10_x86** jako uživatel **student**

2.  Připojte **w10_x86** do domény **testing.local**

    a.  Otevřete System Properties (Vlastnosti systému)

    b.  Na záložce Computer Name (Název počítače) zvolte Change...
        (Změnit\...)

    c.  V části Member of (Je členem) vyberte Domain (Domény) a jako
        název domény zvolte **testing.local**

    d.  Potvrďte OK

    e.  Při výzvě o zadání účtu použijte účet **root**

    f.  Potvrďte OK

    g.  Po připojení do domény proveďte restart

3.  Na **w2022-dc** otevřete **GPME** (*Group Policy Management Editor*)

    a.  Start → Administrative Tools → **Group Policy Management**

4.  Vytvořte nový GPO objekt **32bit Apps GPO** a rovnou ho připojte k
    doméně **testing.local**

    a.  Klikněte pravým na doménu **testing.local** a zvolte Create a
        GPO in this domain, and Link it here...

    b.  Jako název (Name) zvolte **32bit Apps GPO** a u Source Starter
        GPO ponechte (**none**)

    c.  Potvrďte OK

5.  V GPO objektu **32bit Apps GPO** přiřaďte (*assign*) aplikaci
    počítačům

    a.  Klikněte pravým na GPO objekt **32bit Apps GPO** a zvolte
        Edit...

    b.  Vyberte uzel Computer Configuration \\ Policies \\ Software
        Settings

    c.  Klikněte pravým na Software Instalation a zvolte New →
        Package...

    d.  Vyberte instalační soubor **\\\\w2022-dc\\share\\7z920.msi**

    -   Zadaná cesta musí být síťovou cestou k instalačnímu souboru
            aplikace, jinak nebude pro klienta možné lokalizovat na síti
            tento instalační soubor a instalace selže

    e.  U Select deployment method zvolte **Advanced**

    f.  Na záložce Deployment ponechte u Deployment type typ
        **Assigned** a pod Deployment options zaškrtněte nastavení
        **Uninstall this application when it falls out of the scope of
        management**

    g.  Potvrďte OK

    h.  Ukončete GPME

6.  Vytvořte nový WMI filtr **32bit OS**, jenž vybere pouze počítače s
    32-bit operačním systémem

    a.  Klikněte pravým na kontejner WMI Filters a zvolte New...

    b.  Jako název (Name) zvolte **32bit OS** a u Queries zvolte Add

    c.  Jmenný prostor (Namespace) ponechte **root\\CIMv2** a do Query
        zadejte `SELECT \* FROM Win32_OperatingSystem WHERE
        OSArchitecture=\"32-bit\"`

    d.  Vložte dotaz pomocí OK

    e.  Potvrďte vytvoření filtru pomocí Save

7.  Omezte rozsah GPO objektu **32bit Apps GPO** pouze na 32-bit
    operační systémy

    a.  Vyberte GPO objekt **32bit Apps GPO**

    b.  Na záložce Scope v části WMI filtering u This GPO is linked to
        the following WMI filter vyberte v seznamu **32bit OS** a
        potvrďte Yes

8.  Opakujte **body 3 - 6** pro GPO objekt **64bit Apps GPO**,
    instalační soubor **7z920-x64.msi** a WMI filtr `SELECT \* FROM
    Win32_OperatingSystem WHERE OSArchitecture=\"64-bit\"`

9.  Na stanicích **w10_x86** a **w11-domain** spusťte `gpupdate
    /force` a následně je restartujte

    -   Nastavení počítače se aktualizují při startu počítače, nestačí
        se pouze odhlásit

10. Přihlaste se na počítač **w10_x86**, resp. **w11-domain**, jako
    uživatel **homer** a ověřte, že byly nainstalovány aplikace **7-Zip
    9.20**, resp. **7-Zip 9.20 (x64 edition)**

    a.  Otevřete Programs and Features

    1.  Control Panel → Programs and Features

    b.  Zkontrolujte, že je v seznamu přítomen **7-Zip 9.20** resp.
        **7-Zip 9.20 (x64 edition)**

# Bodované úkoly

Úkol 1

-   Zajistěte, aby nastavení v GPO objektu **Enterprise GPO** byla vždy
    aplikována na všechny uživatele a počítače v doméně, s výjimkou
    řadičů domény, dále zajistěte, aby na uživatele, kteří se přihlásí
    na řadič domény, byla aplikována nastavení v GPO objektu **DC GPO**
    ale ne nastavení v GPO objektu **Default Domain Policy**

[^1]: **Gpotool.exe** je k dispozici zde
    <http://go.microsoft.com/fwlink/?linkid=27766>

[^2]: <https://www.microsoft.com/en-us/download/details.aspx?id=57576>
