public with sharing class ComponentData {
    public ComponentData() {
        
    }
    public String hubSelected {get; set;}
    public String dateSelected {get; set;}
    public String cloneFrom {get; set;}


    List <WRAp> wrap = new List <WRAp>();

public class Wrap {
    public String project ;
    public String product;
    public String location;
    public String aantal;
    public Boolean checked;
    
    public Wrap (String location, String project,  String aantal, String product) {
        this.product = product;
        this.project = project;
        this.location = location;
        this.aantal = aantal;
        
    }
}
public void runScript(){




wrap.add(new WRAP('20I3', '2165707', '1', 'Aanhangblad 80 tbv. Cockpitbureau - Pallet'));
wrap.add(new WRAP('20I3', '2165707', '1', 'Ladenblok - Trespa'));
wrap.add(new WRAP('20I3', '2165707', '1', 'Ladenblok - Trespa - Pallet'));
wrap.add(new WRAP('20I3', '2165707', '1', 'Ladenblok'));
wrap.add(new WRAP('20I3', '2165707', '1', 'Aanhangblad 40 Incl. Frame tbv. Cockpitbureau'));
wrap.add(new WRAP('20I4', '2165707', '2', 'Voet tbv. Cockpitbureau - Pallet'));
wrap.add(new WRAP('20I4', '2165707', '1', 'Cockpitburo Onderdelen'));
wrap.add(new WRAP('21A1', '2162204', '3', 'Bouwmaterialen - Heraklith tbv. Rijnstraat 8 - KELDER-1'));
wrap.add(new WRAP('21A2', '2165727', '1', 'Artifort Delta - Bank Onderdelen - Potjes om vast te zetten'));
wrap.add(new WRAP('21A2', '2167298', '1', 'Klok / Paaltje in krat'));
wrap.add(new WRAP('21A2', '2167298', '', 'Klok - Klein'));
wrap.add(new WRAP('21A3', '2165727', '1', 'Artifort Relay tafelsteun met blad'));
wrap.add(new WRAP('21A3', '2165727', '', 'Artifort Relay Tafelblad'));
wrap.add(new WRAP('21A3', '2165727', '', 'Artifort Relay zitschalen'));
wrap.add(new WRAP('21A3', '2165727', '', 'Artifort Relay ligschalen'));
wrap.add(new WRAP('21A3', '2165727', '1', 'Posters KONE Bar'));
wrap.add(new WRAP('21A4', '2165727', '2', 'Zuil tbv. Lounge 2e etage'));
wrap.add(new WRAP('21A4', '2165727', '1', 'Divers RVS Palen afk. Lounge 2'));
wrap.add(new WRAP('21B1', '9900', '4', 'Buro 160x80 - Wit'));
wrap.add(new WRAP('21B2', '2167298', '3', 'Witte Locker Onderdelen afk. Lounge 2 D-Pier'));
wrap.add(new WRAP('21B3', '9900', '2', 'Buro 160x80 - Wit'));
wrap.add(new WRAP('21B3', '9900', '', 'Buroblad 160x80 - Wit'));
wrap.add(new WRAP('21B3', '2167298', '2', 'Plafondroosters Lounge 2'));
wrap.add(new WRAP('21C1', '2161310,5', '2', 'Dubbel Glazen Raam'));
wrap.add(new WRAP('21C1', '2169900', '1', 'Glass Blad 200x100 incl steun op blad'));
wrap.add(new WRAP('21C1', '2169900', '', 'Glass Blad 120x100 incl steun op blad'));
wrap.add(new WRAP('21C1', '2169900', '', 'Lossen Poten'));
wrap.add(new WRAP('21C1', '9900', '1', 'Slede Bijzet Stoel Gestoffeerd - Zwart'));
wrap.add(new WRAP('21C3', '2167298', '4', 'Plafondroosters Lounge 2'));
wrap.add(new WRAP('21D1', '9900', '2', 'Buro 160x80 - Wit'));
wrap.add(new WRAP('21D2', '2167298', '4', 'Plafondroosters Lounge 2'));
wrap.add(new WRAP('2,10E+02', '9900', '4', 'Buro 160x80 - Wit'));
wrap.add(new WRAP('2,10E+03', '2154218', '4', 'Isolatie - (Zwart Folie)'));
wrap.add(new WRAP('2,10E+04', '2167298', '4', 'Plafondroosters Lounge 2'));
wrap.add(new WRAP('21F1', '2160105', '2', 'Kalanders - Schiphol 100-jaar - Pallet'));
wrap.add(new WRAP('21F1', '9900', '2', 'Buro 160x80 - Wit'));
wrap.add(new WRAP('21F2', '2154218', '4', 'Isolatie - (Zwart Folie)'));
wrap.add(new WRAP('21F3', '2167298', '4', 'Plafondroosters Lounge 2'));
wrap.add(new WRAP('20/21 G1', '2165707', '2', 'Aansluitstuk Kersen Directie Buro - Deel.1'));
wrap.add(new WRAP('20/21 G1', '2165707', '', 'Aansluitstuk Kersen Directie Buro - Deel.2'));
wrap.add(new WRAP('20/21 G1', '2165707', '', 'Ronde Lage BIjzettafel'));
wrap.add(new WRAP('21G1', '2165707', '', 'Emotion Buro 160x80'));
wrap.add(new WRAP('21G1', '2165707', '1', 'Hoge Roldeurkast - 195cm'));
wrap.add(new WRAP('21G1', '2167298', '1', 'Profielen - Tussenliggers tbv. Plafond Roosters'));
wrap.add(new WRAP('21G2', '2167298', '1', 'Profielen - Tussenliggers tbv. Plafond Roosters'));
wrap.add(new WRAP('21G2', '2167298', '3', 'Reclamebord Privium Incl. Diversen  op Pallet'));
wrap.add(new WRAP('21G3', '2167298', '2', 'Plafondroosters Lounge 2'));
wrap.add(new WRAP('21G3', '2167298', '1', 'Tussen Liggers tbv. Plafondroosters - Pallet'));
wrap.add(new WRAP('21G4', '2167298', '3', 'Plafondroosters Lounge 2'));
wrap.add(new WRAP('21H1', '2165707', '1', 'Drentea Vergadertafel 140x140 - Wit - Blad Beschadigd'));
wrap.add(new WRAP('21H1', '2165707', '1', 'Emotion Vergadertafel 160x80'));
wrap.add(new WRAP('21H1', '2165707', '1', 'Emotion Cockpitbureau - Compleet'));
wrap.add(new WRAP('21H2', '2167298', '2', 'Plafondroosters Lounge 2'));
wrap.add(new WRAP('21I1', '2165707', '2', 'Rode Middenzone Meubilair - Plantenbak'));
wrap.add(new WRAP('21I1', '2165707', '', 'Rode Middenzone Meubilair - Flatscreen'));
wrap.add(new WRAP('21I1', '9900', '2', 'Bureau 160x80  - Wit - tbv. Verhuur'));
wrap.add(new WRAP('21I1', '2165707', '2', 'Vegader Tafel - Wit 140x140 (gebruikt)'));
wrap.add(new WRAP('21I1', '2165707', '', 'Vegader Tafel - Wit 140x140 (Blad Beschadigd)'));
wrap.add(new WRAP('21I3', '2165707', '1', 'Dreantea - Tafel 80x80 - Wit'));
wrap.add(new WRAP('21I3', '2165500', '1', 'Vlaggen - P4 - Tijdelijk Opslag Regie Centrum'));
wrap.add(new WRAP('21I3', '9900', '1', 'Pallet - Houten Platen'));
wrap.add(new WRAP('21I3', '2155733', '3', 'Rijksmuseum E/F gebied'));
wrap.add(new WRAP('21', '2150103', '63', 'Drentea I.H.V. Bureau 160x80 - Wit'));
wrap.add(new WRAP('21', '2150103', '1', 'Van Dooren I.H.V. Bureau 160x80 - Wit'));
wrap.add(new WRAP('22A1', '2165707', '2', 'Wit Verrijdbaar Whiteboard'));
wrap.add(new WRAP('22A1', '2161200', '4', 'Leanbar 4-Zitter - Beschadigd'));
wrap.add(new WRAP('22A2', '2160932', '4', 'Plafondroosters in kist'));
wrap.add(new WRAP('22A3', '2160932', '4', 'Plafondroosters in kist'));
wrap.add(new WRAP('22B1', '9900', '2', 'Staande Kapstok'));
wrap.add(new WRAP('22B1', '2162204', '3', 'Bouwmaterialen - Heraklith tbv. Rijnstraat 8 - KELDER-1'));
wrap.add(new WRAP('22B1', '2165707', '1', 'Projecten Houder/Standaard'));
wrap.add(new WRAP('22B1', '2165707', '', 'Burostoel Zwart - Gaas Rugleuning'));
wrap.add(new WRAP('22B1', '2165707', '', 'Staande Lamp - Grijs'));
wrap.add(new WRAP('22B2', '2160932', '1', 'Plafondroosters in kist tbv. Holland Boulevard'));
wrap.add(new WRAP('22B2', '2160932', '1', 'Plafondroosters in kist tbv. Holland Boulevard'));
wrap.add(new WRAP('22B2', '2160932', '2', 'Plafondroosters in kist'));
wrap.add(new WRAP('22B3', '2160932', '3', 'Plafondroosters in kist'));
wrap.add(new WRAP('22B3', '2160932', '1', 'Plafondroosters in kist tbv. Holland Boulevard'));
wrap.add(new WRAP('22C1', '9900', '3', 'Hoge Roldeurkast - 195cm'));
wrap.add(new WRAP('22C2', '2160932', '1', 'Plafondroosters in kist'));
wrap.add(new WRAP('22C2', '2160932', '3', 'Plafondroosters in kist tbv. Holland Boulevard'));
wrap.add(new WRAP('22C3', '2160932', '2', 'Plafondroosters in kist tbv. Holland Boulevard'));
wrap.add(new WRAP('22C3', '2160932', '2', 'Plafondroosters in kist'));
wrap.add(new WRAP('22D1', '9900', '1', 'Kamerschermen'));
wrap.add(new WRAP('22D1', '9900', '3', 'Hoge Roldeurkast - 195cm'));
wrap.add(new WRAP('22D2', '2160932', '2', 'Plafondroosters in kist tbv. Holland Boulevard'));
wrap.add(new WRAP('22D2', '2160932', '2', 'Plafondroosters in kist'));
wrap.add(new WRAP('22D3', '2160932', '2', 'Plafondroosters in kist tbv. Holland Boulevard'));
wrap.add(new WRAP('22D3', '2160932', '2', 'Plafondroosters in kist'));
wrap.add(new WRAP('2,20E+03', '2160932', '2', 'Plafondroosters in kist tbv. Holland Boulevard'));
wrap.add(new WRAP('2,20E+04', '2160932', '2', 'Plafondroosters in kist'));
wrap.add(new WRAP('2,20E+04', '2160932', '2', 'Plafondroosters in kist tbv. Holland Boulevard'));
wrap.add(new WRAP('22F1', '2165707', '3', 'Hoge Roldeurkast - 195cm'));
wrap.add(new WRAP('22F2', '2160932', '1', 'Plafondroosters in kist'));
wrap.add(new WRAP('22F2', '2157998', '1', 'Isolatie - Pallet'));
wrap.add(new WRAP('22F2', '2160932', '2', 'Plafondroosters in kist tbv. Holland Boulevard'));
wrap.add(new WRAP('22G1', '2162204', '2', 'Lensvelt - RS8 - Lounge Fauteuil - Beige - Etage 2 B-Z'));
wrap.add(new WRAP('22G1', '2162204', '2', 'Lensvelt - RS8 - Lounge Fauteuil - Beige - Etage 10 E'));
wrap.add(new WRAP('22G2', '2161020', '1', 'Elektra Verdeelkast tbv. Lounge 2'));
wrap.add(new WRAP('22G2', '2161020', '', 'Glazen Lamp tbv. Lounge 2'));
wrap.add(new WRAP('22G2', '2161020', '1', 'Glazen Lamp tbv. Lounge 2'));
wrap.add(new WRAP('22G2', '2161020', '1', 'Armaturen'));
wrap.add(new WRAP('22G2', '2161020', '', 'Glazen Lamp tbv. Lounge 2'));
wrap.add(new WRAP('22G2', '2161020', '1', 'Analoge Klok tbv. Lounge 2'));
wrap.add(new WRAP('22G3', '2160932', '1', 'Plafondroosters in kist'));
wrap.add(new WRAP('22H1', '2154218', '3', 'Plafond Systeem - Hunter Douglas tbv. Crew Bagage (Plafond Platen)(Luxalon)'));
wrap.add(new WRAP('22I1', '2154218', '3', 'Plafond Systeem - Hunter Douglas tbv. Crew Bagage (Plafond Platen)(Luxalon)'));
wrap.add(new WRAP('22I1', '2169233,03', '3', 'Meubelen'));
wrap.add(new WRAP('22I1', '2162204', '3', 'Integra - RS8 - Plafond Plaat - Etage 5'));
wrap.add(new WRAP('22I2', '2165400', '3', 'Oranje zitgelegenheden tbv. Holland Boulevard'));
wrap.add(new WRAP('23A1', '2161200', '3', 'Artifort Delta Bank - Compleet'));
wrap.add(new WRAP('23A2', '2150103', '1', 'Tussenwand - Buro Onderdeel'));
wrap.add(new WRAP('23A2', '2160932', '3', 'Plafondroosters'));
wrap.add(new WRAP('23A3', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('23A3', '2160932', '3', 'Plafondroosters'));
wrap.add(new WRAP('23A4', '2150103', '4', 'Drentea - Bruce Stoel - Zwart - Incl. Armleuning'));
wrap.add(new WRAP('23B1', '2162204', '3', 'Bouwmaterialen - Heraklith + Toebehoren tbv. Rijnstraat - KELDER-1'));
wrap.add(new WRAP('23B2', '2150103', '1', 'Griptafel'));
wrap.add(new WRAP('23B2', '2165723', '1', 'FF3 prullenbak'));
wrap.add(new WRAP('23B2', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('23B3', '9900', '1', 'Sta-Tafel Vierkant blad - Wit'));
wrap.add(new WRAP('23B3', '9900', '1', 'Ladenblok - Grijs'));
wrap.add(new WRAP('23B3', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('23B4', '2150103', '3', 'Drentea - Bruce Stoel - Zwart - Incl. Armleuning'));
wrap.add(new WRAP('23B4', '2150103', '1', 'Drentea - Bruce Stoel - Zwart - Excl. Armleuning'));
wrap.add(new WRAP('23C1', '2161103', '1', 'Bureau - Wit 160x80'));
wrap.add(new WRAP('23C2', '9900', '2', 'Houten platen'));
wrap.add(new WRAP('23C2', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('23C2', '9900', '1', 'Lage Roldeurkast 105cm - Incl. Sleutel'));
wrap.add(new WRAP('23C3', '9900', '2', 'Lage Roldeurkast 105cm - Incl. Sleutel'));
wrap.add(new WRAP('23C3', '9900', '1', 'Houten platen'));
wrap.add(new WRAP('23C4', '2160932', '4', 'Plafondroosters'));
wrap.add(new WRAP('23D1', '9900', '2', 'Kamerschermen - Nieuw'));
wrap.add(new WRAP('23D2', '9900', '2', 'Bureau 160x80 - Zilver Frame'));
wrap.add(new WRAP('23D2', '2160932', '2', 'Plafondroosters'));
wrap.add(new WRAP('23D3', '9900', '4', 'Bureau 160x80 - Zilver Frame'));
wrap.add(new WRAP('23D4', '2150103', '1', 'Tafel Poot - Moooi'));
wrap.add(new WRAP('23D4', '2150103', '1', 'Tafel Blad - Moooi'));
wrap.add(new WRAP('23D4', '2150103', '', 'Tafel Poot - Moooi'));
wrap.add(new WRAP('2,30E+02', '2153204', '1', 'RH Logic 24uurs Stoel'));
wrap.add(new WRAP('2,30E+03', '2165707', '1', 'Drentea - Bruce - Wit 120x80 (gebruikt)'));
wrap.add(new WRAP('2,30E+03', '2160932', '1', 'Plafond profielen'));
wrap.add(new WRAP('2,30E+03', '2153201', '1', 'Middenzone Roldeurkast 135 cm - Grijs'));
wrap.add(new WRAP('2,30E+03', '2153201', '', 'Muuto Lamp'));
wrap.add(new WRAP('2,30E+03', '2153201', '', 'Nordlux Klaassen - Float Lamp'));
wrap.add(new WRAP('2,30E+03', '2153201', '', 'Rendierenkop'));
wrap.add(new WRAP('2,30E+03', '2153201', '', 'Zuiver Lamp'));
wrap.add(new WRAP('2,30E+03', '2153201', '', 'Whiteboard Starterskit'));
wrap.add(new WRAP('2,30E+03', '9900', '1', 'Bijzet Stoel - Blauw'));
wrap.add(new WRAP('2,30E+03', '9900', '', 'Bijzet Stoel - Zwart'));
wrap.add(new WRAP('2,30E+04', '2159900', '2', 'Bureau 160x80 - Wit - Excl. Slinger'));
wrap.add(new WRAP('2,40E+05', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('2,30E+05', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('23F1', '2162204', '1', 'Lensvelt - RS8 - Lounge Fauteuil - Beige - Etage 7 E'));
wrap.add(new WRAP('23F1', '2162204', '1', 'Lensvelt - RS8 - Lounge Fauteuil - Beige - Etage 6 E'));
wrap.add(new WRAP('23F2', '2159900', '2', 'Bureau 160x80 - Wit - Excl. Slinger'));
wrap.add(new WRAP('23F2', '2159900', '', 'Bureau 160x80 - Wit'));
wrap.add(new WRAP('23F2', '2159900', '', 'Bureau 160x80 - Wit (Beschadigd)'));
wrap.add(new WRAP('23F2', '2153201', '2', 'Poten + Frames tbv. Witte Bureaus'));
wrap.add(new WRAP('23F2', '2153201', '', 'Muuto Unfold'));
wrap.add(new WRAP('23F3', '2153201', '2', 'Sitlife Polaris Bureau Stoel - Zwart'));
wrap.add(new WRAP('23F3', '2159900', '', 'Bureau 160x80 - Wit - Excl. Slinger'));
wrap.add(new WRAP('23F3', '2162204', '2', 'MultiDesk - RS8 - Lounge Tafel - Etage 8 DE-Z'));
wrap.add(new WRAP('23F4', '9900', '3', 'Tafel 160x90 IHV Verstelbaar - Beige'));
wrap.add(new WRAP('23F4', '9900', '', 'Tafel 180x90 IHV Verstelbaar - Beige'));
wrap.add(new WRAP('23F4', '2165707', '1', 'Drentea - Bruce - Wit 80x80 (gebruikt)'));
wrap.add(new WRAP('23G1', '2162204', '1', 'Lensvelt - RS8 - Lounge Fauteuil - Beige - Etage 2 B-Z'));
wrap.add(new WRAP('23G2', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('23G2', '9900', '3', 'Tafel 180x90 IHV Verstelbaar - Beige'));
wrap.add(new WRAP('23G3', '2150103', '2', 'Vergader Tafel - Blad 140x140 Wit'));
wrap.add(new WRAP('23G3', '2150103', '2', 'Vergader Tafel - Frame 140x140 Wit'));
wrap.add(new WRAP('23G4', '2165400', '4', 'Half ronde lampen tbv. Holland Boulevard in Kist'));
wrap.add(new WRAP('23H1', '2162204', '1', 'Lensvelt - RS8 - Lounge Fauteuil - Beige - Etage 8 E'));
wrap.add(new WRAP('23H1', '2154218', '3', 'Plafond Systeem - Hunter Douglas tbv. Crew Bagage (Plafond Platen)(Luxalon)'));
wrap.add(new WRAP('23H2', '9900', '3', 'Tafel 180x90 IHV Verstelbaar - Beige'));
wrap.add(new WRAP('23H2', '2160932', '1', 'Plafondroosters tbv. AAS+ Wortel E-pier'));
wrap.add(new WRAP('23H3', '2162204', '1', 'Lensvelt - RS8 - Lounge Fauteuil - Beige - Etage 2 B-Z'));
wrap.add(new WRAP('23H4', '2165400', '3', 'Delen van de Holland Boulevard'));
wrap.add(new WRAP('23I1', '2162204', '6', 'Integra - RS8 - Plafond Plaat - Etage 5'));
wrap.add(new WRAP('23I2', '9900', '2', 'Tafel 180x90 IHV Verstelbaar - Beige'));
wrap.add(new WRAP('23I2', '2162204', '2', 'MultiDesk - RS8 - Bureaubladen - Etage 8 DE-Z / EN'));
wrap.add(new WRAP('23I3', '2161020', '4', 'Divers Goederen afk. Keet Heijmans - Pallet'));
wrap.add(new WRAP('23I4', '2162204', '2', 'MultiDesk - RS8 - Lounge Tafel - Etage 6 BC'));
wrap.add(new WRAP('23I4', '9900', '1', 'Poef  - Donker Blauw'));
wrap.add(new WRAP('24A', '2160809', '4', 'Diverse Profielen  - Staat tegen de muur'));
wrap.add(new WRAP('24A1', '2160932', '3', 'Plafondroosters'));
wrap.add(new WRAP('24A2', '2162204', '3', 'Bouwmaterialen - Heraklith tbv. Rijnstraat 8 - KELDER-1'));
wrap.add(new WRAP('24A3', '2162204', '2', 'MultiDesk - RS8 - Bureaubladen - Etage 6 DE-N'));
wrap.add(new WRAP('24A3', '2162204', '2', 'MultiDesk - RS8 - Bureaubladen - Etage 6 DEZ / DE-Z'));
wrap.add(new WRAP('24A4', '2162204', '2', 'MultiDesk - RS8 - Bureaubladen - Etage 6 E-N / E-Z'));
wrap.add(new WRAP('24A4', '2162204', '2', 'MultiDesk - RS8 - Bureaubladen - Etage 6 D-N'));
wrap.add(new WRAP('24B1', '2160932', '3', 'Plafondroosters'));
wrap.add(new WRAP('24B2', '2162204', '3', 'Bouwmaterialen - Heraklith + Toebehoren tbv. Rijnstraat - KELDER-1'));
wrap.add(new WRAP('24B2', '9900', '3', 'Bureau 180x80 IHV - Hoog Model - Beuken'));
wrap.add(new WRAP('24B4', '2162204', '2', 'MultiDesk - RS8 - Bureaubladen - Etage 7 C-N'));
wrap.add(new WRAP('24C1', '2160932', '3', 'Plafondroosters'));
wrap.add(new WRAP('24C2', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('24C2', '2162204', '3', 'Bouwmaterialen - Heraklith  tbv. Rijnstraat - KELDER-1'));
wrap.add(new WRAP('24C3', '2162204', '2', 'MultiDesk - RS8 - Bureaubladen - Etage 7 D-Z / E-Z'));
wrap.add(new WRAP('24C4', '2160932', '4', 'Plafondroosters (1/10), (2/10), (3/10), (7/10)'));
wrap.add(new WRAP('24D1', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('24D1', '2165707', '3', 'Rode Middenzone Meubilair - Plantenbak'));
wrap.add(new WRAP('24D2', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('24D2', '9900', '2', 'Bureau 180x80 IHV - Hoog Model - Beuken'));
wrap.add(new WRAP('24D2', '2162204', '3', 'Bouwmaterialen - Heraklith  tbv. Rijnstraat - KELDER-1'));
wrap.add(new WRAP('24D3', '2160932', '4', 'Plafondroosters (4/10), (5/10), (8/10)'));
wrap.add(new WRAP('24D4', '2160932', '4', 'Plafondroosters (6/10), (9/10), (10/10)'));
wrap.add(new WRAP('2,40E+02', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('2,40E+02', '2165707', '2', 'Middenzone Meubilair - Rode Plantenbak'));
wrap.add(new WRAP('2,40E+03', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('2,40E+03', '9900', '3', 'Tafel 180x90 IHV Verstelbaar - Beige'));
wrap.add(new WRAP('2,40E+04', '2160932', '2', 'Plafondroosters'));
wrap.add(new WRAP('2,40E+04', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('24F1', '2160932', '4', 'Glazen Ruit Groot met oude Schiphol logo'));
wrap.add(new WRAP('24F2', '2162204', '2', 'MultiDesk - RS8 - Bureaubladen - Etage 7 DE-N'));
wrap.add(new WRAP('24F3', '9900', '3', 'Tafel 180x90 IHV Verstelbaar - Beige'));
wrap.add(new WRAP('24G1', '2160932', '1', 'Plafondroosters'));
wrap.add(new WRAP('24G2', '2162204', '3', 'Bouwmaterialen - Heraklith  tbv. Rijnstraat - KELDER-1'));
wrap.add(new WRAP('24G2', '9900', '2', 'Bureau 160x80  - Wit - tbv. Verhuur'));
wrap.add(new WRAP('24G2', '2162204', '2', 'MultiDesk - RS8 - Lounge Tafel - Etage 7 E-N'));
wrap.add(new WRAP('24G3', '2162204', '3', 'HWC (Heraklith) Platen tbv. Rijnstraat 8 - KELDER-1'));
wrap.add(new WRAP('24G4', '9900', '3', 'Tafel 200x90 IHV Verstelbaar - Beige'));
wrap.add(new WRAP('24H1', '2165707', '2', 'Prototype Bureau - Wit 160x80'));
wrap.add(new WRAP('24H1', '2165707', '2', 'Prototype Vergader Tafel - Wit 140x140'));
wrap.add(new WRAP('24H1', '2165707', '2', ''));
wrap.add(new WRAP('24H1', '2165400', '4', 'Strippenpui zwart op stalen bok'));
wrap.add(new WRAP('24H1', '2150103', '2', 'Drentea Vergadertafel 140x140 - Wit'));
wrap.add(new WRAP('24H2', '2162204', '3', 'Bouwmaterialen - Heraklith  tbv. Rijnstraat - KELDER-1'));
wrap.add(new WRAP('24H2', '9900', '2', 'Bureau 160x80  - Wit - tbv. Verhuur'));
wrap.add(new WRAP('24H2', '2162204', '2', 'MultiDesk - RS8 - Lounge Tafel - Etage 8 DE-Z'));
wrap.add(new WRAP('24H3', '9900', '2', 'Tafel 180x90 IHV Verstelbaar - Beige'));
wrap.add(new WRAP('24H3', '9900', '2', 'Bureau 160x80  - Wit - tbv. Verhuur'));
wrap.add(new WRAP('24H4', '9900', '4', 'RVS Banklinning'));
wrap.add(new WRAP('24I2', '2162204', '2', 'MultiDesk - RS8 - Bureaubladen - Etage 8 D-Z / DE-N / D-N'));
wrap.add(new WRAP('24I2', '2160809', '2', 'Houten Platen - Divers op Pallet'));
wrap.add(new WRAP('24I3', '2162204', '1', 'MultiDesk - RS8 - Bureaubladen - Etage 9 D-N / D-Z'));
wrap.add(new WRAP('24I3', '2162204', '1', 'MultiDesk - RS8 - Bureaubladen - Etage 10 D-N / D- Z'));
wrap.add(new WRAP('24I3', '2162204', '1', 'MultiDesk - RS8 - Bureaubladen - Etage 7D-N'));
wrap.add(new WRAP('25A1', '2165707', '2', 'Rode Middenzone Meubilair - Plantenbak'));
wrap.add(new WRAP('25A4', '2150103', '2', 'Drentea - Bruce Stoel - Zwart - Incl. Armleuning'));
wrap.add(new WRAP('25B1', '9900', '4', '5-Deurs Kleding Lockers - Blauw'));
wrap.add(new WRAP('25B2', '', '1', 'Tecno GTS Peronbank tbv. Ad de Backer - Compleet'));
wrap.add(new WRAP('25B4', '2150103', '3', 'Drentea - Bruce Stoel - Zwart - Incl. Armleuning'));
wrap.add(new WRAP('25B4', '2150103', '1', 'Drentea - Bruce Stoel - Zwart - Excl. Armleuning'));
wrap.add(new WRAP('25C1', '9900', '4', '5-Deurs Kleding Lockers - Blauw'));
wrap.add(new WRAP('25C2', '2150103', '2', 'Drentea - Bruce Stoel - Zwart - Excl. Armleuning'));
wrap.add(new WRAP('25C2', '2160809', '1', 'Tapijt Tegels - Pallet'));
wrap.add(new WRAP('25C2', '2160809', '1', 'Printer'));
wrap.add(new WRAP('25C2', '2160809', '', 'Diverse Goederen in dozen'));
wrap.add(new WRAP('25C3', '2150103', '2', 'Divers Onderdelen tbv. Drentea Bureau - Pallet'));
wrap.add(new WRAP('25C3', '2150103', '', 'Oranje Hang Lamp'));
wrap.add(new WRAP('25C3', '2150103', '1', 'Topbladen - Wit tbv. Kasten'));
wrap.add(new WRAP('25C4', '2150103', '1', 'Drentea - Bruce Stoel - Grijs - Excl. Armleuning'));
wrap.add(new WRAP('25C4', '2150103', '', 'Drentea - Bruce Stoel - Zwart - Incl. Armleuning'));
wrap.add(new WRAP('25C4', '2150103', '1', 'Drentea - Bruce Stoel - Grijs - Excl. Armleuning'));
wrap.add(new WRAP('25C4', '2150103', '2', 'Drentea - Bruce Stoel - Grijs - Incl. Armleuning'));
wrap.add(new WRAP('25D1', '9900', '2', '5-Deurs Kleding Lockers - Blauw'));
wrap.add(new WRAP('23D1', '9900', '2', 'Kamerschermen'));
wrap.add(new WRAP('25D2', '2160809', '1', 'Tapijt Tegels - Pallet'));
wrap.add(new WRAP('25D3', '2160809', '1', 'Tapijt Tegels - Pallet'));
wrap.add(new WRAP('25D4', '2150103', '4', 'Drentea - Bruce Stoel - Zwart - Excl. Armleuning'));
wrap.add(new WRAP('2,50E+02', '9900', '2', 'Kamerschermen'));
wrap.add(new WRAP('2,50E+03', '2150103', '1', 'Drentea - Bruce Stoel - Zwart - Excl. Armleuning'));
wrap.add(new WRAP('2,50E+04', '2150103', '', 'Meubesl tbv. Pro. HNW Treminal West As 1x Pallet'));
wrap.add(new WRAP('2,50E+05', '2160809', '2', 'Tapijt Tegels - Pallet'));
wrap.add(new WRAP('25F1', '9900', '2', 'Kamerschermen'));
wrap.add(new WRAP('25F2', '2150103', '4', 'Drentea - Bruce Stoel - Zwart - Excl. Armleuning'));
wrap.add(new WRAP('25F3', '2150103', '4', 'Lage Roldeurkast 105cm - Wit'));
wrap.add(new WRAP('25F4', '2150103', '4', 'Lage Roldeurkast 105cm - Wit'));
wrap.add(new WRAP('24G1', '9900', '2', 'Suez - Bouwbewust Box - Groen'));
wrap.add(new WRAP('25G1', '2162204', '4', 'Lensvelt - RS8 - Vergader Stoel - LUXE - Etage 15 DE-Z'));
wrap.add(new WRAP('25G2', '2150103', '4', 'Lage Roldeurkast 105cm - Wit'));
wrap.add(new WRAP('25G3', '2150103', '4', 'Lage Roldeurkast 105cm - Wit'));











    Set <String> productNames = new Set <String>();
    Set <String> projectNames = new Set <String>();
    Set <String> locationNames = new Set <String>();
    
    for (WRAP wrapL: wrap){
        productNames.add(wrapL.product);
        projectNames.add(wrapL.project);
        locationNames.add(wrapL.location);
    }
    List <WWW_detail__c> details = [select Id, Location__r.Name, Project__r.Name, Item_Name__c from WWW_detail__c where (Location__r.Name in:locationNames and Project__r.Name in : projectNames and Item_Name__c in : productNames) and LastModifiedDate !=: date.Today()];
    System.debug('OLD ' + details.size() + ' ' + details);
    Set <WWW_detail__c> setD = new Set <WWW_detail__c>();
    Set <Id>ids = new Set<Id>();
    List <WWW_detail__c> toUpdate = new List <WWW_detail__c>();
    for (WWW_detail__c det: details) {
        for (WRAP wrapL: wrap) {
            if (wrapL.product == det.Item_Name__c && wrapL.location == det.Location__r.Name && det.Project__r.Name == wrapL.Project) {
                if (wrapL.aantal!='') {
                    wrapl.checked = true;
                    det.Toename_palletplaatsen__c = Decimal.valueOf(wrapL.aantal);
                }
                
                if (!setD.contains(det) && det.id != 'a0s24000001CzajAAC' && !ids.contains(det.id)) {
                ids.add(det.id);
                setD.add(det);}
            } 
        }
    }
    toUpdate.addAll(setD);
    System.debug('NEW ' + toUpdate.size() + ' ' + toUpdate);
    update toUpdate;
        for (WRAP wrapL: wrap){
            if (wrapl.checked == null || !wrapl.checked) {
                System.debug('wrapL ' + wrapL);
            } 
        }
}
}