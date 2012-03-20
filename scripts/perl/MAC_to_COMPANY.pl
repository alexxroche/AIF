#!/usr/bin/perl

=head1 Name

MAC_to_COMPANY.pl

=head1 Description

Give it a MAC and it will search for a company

=head1 BUGS

The matching needs to be improved

=head1 LICENSE AND COPYRIGHT

Copyright 2010-2012 Alexx Roche C<alexx at cpan dor org>, all rights reserved.

This program is free software; you can redistribute it and/or modify it
under the terms of either: Eclipse Public License, Version 1.0 ; 
 the GNU Lesser General Public License as published 
by the Free Software Foundation; or the Artistic License.

See http://www.opensource.org/licenses/ for more information.

=cut

use strict;
#no strict "refs";
my %opt=(d=>0, q=>1);
$|=1;

sub help{
    print "Usage: $0 mac_address\n";
    print " [-d|-h|-v|-q|-l|-v], -q(uick) search enabled by default\n";
    print "Copyright 2010-2012 Cahiravahilla publications\n";
    exit(0);
}

unless($ARGV[0]){&help;}

for(my $args=0;$args<=(@ARGV -1);$args++){
        if    ($ARGV[$args]=~m/^-+h/i){ &help; }
        elsif ($ARGV[$args] eq '-d'){ $opt{d}++; print "debug enabled\n" unless $opt{d}; }
        elsif ($ARGV[$args] eq '-l'){ $opt{l}++; $opt{q}=0; print "long search enabled, (quick search disabled)\n" unless $opt{l}; }
        elsif ($ARGV[$args] eq '-q'){ $opt{q}++; $opt{l}=0; print "quick search enabled, (long search disabled)\n" unless $opt{q}; }
        elsif ($ARGV[$args] eq '-v'){ $opt{v}++;  print "Verbose output enabled\n" unless $opt{v};}
        else{ 
            if($opt{query} && $opt{query}!~m/[^0-9a-f]$/i && $ARGV[$args]!~m/^[^0-9a-f]/){ $opt{query} .= ':'; }
            $opt{query}.= $ARGV[$args]; 
        }
}

if($opt{query}){
    $opt{query}=~s/[-_]/:/g;
    $opt{query}=~s/::/:/g;
    $opt{query}=uc($opt{query});
    unless($opt{query}=~m/:/){ print "$opt{query} does not look like a MAC address to me\n"; exit; }
    my @s = split/:/, $opt{query};
    print "You are looking for: " . join('', @s) . " ($opt{query})\n" if $opt{v}>=1;
    my $count=0;
    LINE: while(<DATA>){
        $count++;
        my @query = @s;
        $_=~s/\s+/ /g;
        $_=~s/^\s+//g;
        $_= uc($_);
        my @phrase = split('#', $_);
        my @line = split(' ', $phrase[0]);
        my $args = @line;
        if("$line[0] $line[1]" ne "@line"){
            # we are not on a data line, probably a comment of some sort
            $line[1] .= "[TR]: " . @line;
        }
        print "$count\t: $args a: $line[0] b:$line[1] => $phrase[1]\n" if $opt{d}>=5;
        next LINE unless ( @line == 2 );
        $line[0]=~s/-/:/g;
        # lets compare this line with the query
        my $this_mac;
        my $depth_count=0;
        while(@query){
            #$this_mac .= join(':', shift @query);
            $this_mac .=  ':' if $this_mac ne '';
            $this_mac .=  shift @query;
            $depth_count++;
            #next LINE unless $line[0]=~m/^$this_mac/;
            unless ($line[0]=~m/^$this_mac/){
              if($depth_count >= $opt{depth} || $opt{d}>=2){
                print "$line[0]!~ $this_mac (bm:$opt{best_match} dpth:$opt{depth})\n" if $opt{d}>=2;
              }
                next LINE;
            }
            if($depth_count > $opt{depth}){
                $opt{depth}= $depth_count;
                $opt{best_match}= $_;
                print "$this_mac matches $line[0] ($line[1], $phrase[1]\n" if $opt{d}>=1;
                last LINE if ($opt{depth}==3 && $opt{q}==1);
            }
        }
    }
    $opt{sure} = 'might be';
    if($opt{depth}>=4){ $opt{sure}='is'; }
    if(defined($opt{'best_match'})){
        print $opt{depth};
        print " $opt{query} $opt{sure} $opt{'best_match'}\n";
        exit(0);
    }else{
        print $opt{depth};
        print " I have no idea who $opt{query} $opt{sure}\n";
        exit(1);
    }
}

=head1 Source

# The data below has been assembled from the following sources:
#
# The IEEE public OUI listing available from:
# http://standards.ieee.org/regauth/oui/index.shtml
# http://standards.ieee.org/regauth/oui/oui.txt
#
# Michael Patton's "Ethernet Codes Master Page" available from:
# <http://www.cavebear.com/CaveBear/Ethernet/>
# <ftp://ftp.cavebear.com/pub/Ethernet.txt>
#
# The Wireshark 'manuf' file, which started out as a subset of Michael
# Patton's list and grew from there.

#
# Well-known addresses.
#
# $Id$
#
# Wireshark - Network traffic analyzer
# By Gerald Combs <gerald [AT] wireshark.org>
# Copyright 1998 Gerald Combs
#
# The data below has been assembled from the following sources:
#
# Michael Patton's "Ethernet Codes Master Page" available from:
# <http://www.cavebear.com/CaveBear/Ethernet/>
# <ftp://ftp.cavebear.com/pub/Ethernet.txt>
# Microsoft Windows 2000 Server
# Operating System
# Network Load Balancing Technical Overview
# White Paper

=head2 Format

MAC COMPANY Name # optional comment

=cut

__DATA__
00:00:00	00:00:00	# Officially Xerox, but 0:0:0:0:0:0 is more common
00:00:01	Xerox                  # XEROX CORPORATION
00:00:02	Xerox                  # XEROX CORPORATION
00:00:03	Xerox                  # XEROX CORPORATION
00:00:04	Xerox                  # XEROX CORPORATION
00:00:05	Xerox                  # XEROX CORPORATION
00:00:06	Xerox                  # XEROX CORPORATION
00:00:07	Xerox                  # XEROX CORPORATION
00:00:08	Xerox                  # XEROX CORPORATION
00:00:09	Xerox                  # XEROX CORPORATION
00:00:0A	OmronTatei             # OMRON TATEISI ELECTRONICS CO.
00:00:0B	Matrix                 # MATRIX CORPORATION
00:00:0C	Cisco                  # CISCO SYSTEMS, INC.
00:00:0D	Fibronics              # FIBRONICS LTD.
00:00:0E	Fujitsu                # FUJITSU LIMITED
00:00:0F	Next                   # NEXT, INC.
00:00:10	Hughes
00:00:11	Tektrnix
00:00:12	Informatio             # INFORMATION TECHNOLOGY LIMITED
00:00:13	Camex
00:00:14	Netronix
00:00:15	Datapoint              # DATAPOINT CORPORATION
00:00:16	DuPontPixe             # DU PONT PIXEL SYSTEMS     .
00:00:17	Tekelec
00:00:18	WebsterCom             # WEBSTER COMPUTER CORPORATION
00:00:19	AppliedDyn             # APPLIED DYNAMICS INTERNATIONAL
00:00:1A	AMD
00:00:1B	Novell                 # NOVELL INC.
00:00:1C	BellTechno             # BELL TECHNOLOGIES
00:00:1D	Cabletron              # CABLETRON SYSTEMS, INC.
00:00:1E	TelsistInd             # TELSIST INDUSTRIA ELECTRONICA
00:00:1F	Telco                  # Telco Systems, Inc.
00:00:20	DIAB
00:00:21	SC&C
00:00:22	VisualTech             # VISUAL TECHNOLOGY INC.
00:00:23	AbbIndustr             # ABB INDUSTRIAL SYSTEMS AB
00:00:24	Olicom
00:00:25	Ramtek                 # RAMTEK CORP.
00:00:26	Sha-Ken                # SHA-KEN CO., LTD.
00:00:27	JapanRadio             # JAPAN RADIO COMPANY
00:00:28	Prodigy                # PRODIGY SYSTEMS CORPORATION
00:00:29	ImcNetwork             # IMC NETWORKS CORP.
00:00:2A	Trw-Sedd/I             # TRW - SEDD/INP
00:00:2B	CrispAutom             # CRISP AUTOMATION, INC
00:00:2C	Autotote               # AUTOTOTE LIMITED
00:00:2D	Chromatics             # CHROMATICS INC
00:00:2E	SocieteEvi             # SOCIETE EVIRA
00:00:2F	Timeplex               # TIMEPLEX INC.
00:00:30	VgLaborato             # VG LABORATORY SYSTEMS LTD
00:00:31	QpsxCommun             # QPSX COMMUNICATIONS PTY LTD
00:00:32	Marconi                # Marconi plc
00:00:33	EganMachin             # EGAN MACHINERY COMPANY
00:00:34	NetworkRes             # NETWORK RESOURCES CORPORATION
00:00:35	Spectragra             # SPECTRAGRAPHICS CORPORATION
00:00:36	Atari                  # ATARI CORPORATION
00:00:37	OxfordMetr             # OXFORD METRICS LIMITED
00:00:38	CssLabs                # CSS LABS
00:00:39	Toshiba                # TOSHIBA CORPORATION
00:00:3A	Chyron                 # CHYRON CORPORATION
00:00:3B	IControls              # i Controls, Inc.
00:00:3C	Auspex                 # AUSPEX SYSTEMS INC.
00:00:3D	AT&T
00:00:3E	Simpact
00:00:3F	Syntrex                # SYNTREX, INC.
00:00:40	Applicon               # APPLICON, INC.
00:00:41	Ice                    # ICE CORPORATION
00:00:42	MetierMana             # METIER MANAGEMENT SYSTEMS LTD.
00:00:43	MicroTechn             # MICRO TECHNOLOGY
00:00:44	Castelle               # CASTELLE CORPORATION
00:00:45	FordAerosp             # FORD AEROSPACE & COMM. CORP.
00:00:46	ISC-BR
00:00:47	NicoletIns             # NICOLET INSTRUMENTS CORP.
00:00:48	SeikoEpson             # SEIKO EPSON CORPORATION
00:00:49	ApricotCom             # APRICOT COMPUTERS, LTD
00:00:4A	AdcCodenol             # ADC CODENOLL TECHNOLOGY CORP.
00:00:4B	APT
00:00:4C	Nec                    # NEC CORPORATION
00:00:4D	Dci                    # DCI CORPORATION
00:00:4E	Ampex                  # AMPEX CORPORATION
00:00:4F	Logicraft              # LOGICRAFT, INC.
00:00:50	Radisys                # RADISYS CORPORATION
00:00:51	HobElectro             # HOB ELECTRONIC GMBH & CO. KG
00:00:52	IntrusionC             # Intrusion.com, Inc.
00:00:53	Compucorp
00:00:54	Modicon                # MODICON, INC.
00:00:55	AT&T
00:00:56	DrBStruck              # DR. B. STRUCK
00:00:57	Scitex                 # SCITEX CORPORATION LTD.
00:00:58	RacoreComp             # RACORE COMPUTER PRODUCTS INC.
00:00:59	Hellige                # HELLIGE GMBH
00:00:5A	Syskonnect             # SysKonnect GmbH
00:00:5B	EltecElekt             # ELTEC ELEKTRONIK AG
00:00:5C	Telematics             # TELEMATICS INTERNATIONAL INC.
00:00:5D	CsTelecom              # CS TELECOM
00:00:5E	UscInforma             # USC INFORMATION SCIENCES INST
00:00:5F	SumitomoEl             # SUMITOMO ELECTRIC IND., LTD.
00:00:60	KontronEle             # KONTRON ELEKTRONIK GMBH
00:00:61	GatewayCom             # GATEWAY COMMUNICATIONS
00:00:62	Hneywell	# Honeywell
00:00:63	HP
00:00:64	YokogawaDi             # YOKOGAWA DIGITAL COMPUTER CORP
00:00:65	NetworkGen             # Network General Corporation
00:00:66	Talaris                # TALARIS SYSTEMS, INC.
00:00:67	Soft*Rite              # SOFT * RITE, INC.
00:00:68	RosemountC             # ROSEMOUNT CONTROLS
00:00:69	SGI
00:00:6A	ComputerCo             # COMPUTER CONSOLES INC.
00:00:6B	MIPS
00:00:6C	Private
00:00:6D	CrayCommun             # CRAY COMMUNICATIONS, LTD.
00:00:6E	Artisoft               # ARTISOFT, INC.
00:00:6F	Madge                  # Madge Ltd.
00:00:70	Hcl                    # HCL LIMITED
00:00:71	Adra                   # ADRA SYSTEMS INC.
00:00:72	MiniwareTe             # MINIWARE TECHNOLOGY
00:00:73	Siecor                 # SIECOR CORPORATION
00:00:74	Ricoh                  # RICOH COMPANY LTD.
00:00:75	NortelNetw             # Nortel Networks
00:00:76	AbekasVide             # ABEKAS VIDEO SYSTEM
00:00:77	Interphase             # INTERPHASE CORPORATION
00:00:78	Labtam                 # LABTAM LIMITED
00:00:79	Networth               # NETWORTH INCORPORATED
00:00:7A	Ardent
00:00:7B	ResearchMa             # RESEARCH MACHINES
00:00:7C	Ampere                 # AMPERE INCORPORATED
00:00:7D	Cray
00:00:7E	Clustrix               # CLUSTRIX CORPORATION
00:00:7F	Linotype-H             # LINOTYPE-HELL AG
00:00:80	CrayCommun             # CRAY COMMUNICATIONS A/S
00:00:81	BayNetwork             # BAY NETWORKS
00:00:82	LectraSyst             # LECTRA SYSTEMES SA
00:00:83	TadpoleTec             # TADPOLE TECHNOLOGY PLC
00:00:84	Supernet
00:00:85	Canon                  # CANON INC.
00:00:86	Megahertz              # MEGAHERTZ CORPORATION
00:00:87	Hitachi                # HITACHI, LTD.
00:00:88	ComputerNe             # COMPUTER NETWORK TECH. CORP.
00:00:89	Cayman                 # CAYMAN SYSTEMS INC.
00:00:8A	DatahouseI             # DATAHOUSE INFORMATION SYSTEMS
00:00:8B	Infotron
00:00:8C	AlloyCompu             # Alloy Computer Products (Australia) Pty Ltd
00:00:8D	Verdix                 # VERDIX CORPORATION
00:00:8E	SolbourneC             # SOLBOURNE COMPUTER, INC.
00:00:8F	Raytheon               # RAYTHEON COMPANY
00:00:90	Microcom
00:00:91	Anritsu                # ANRITSU CORPORATION
00:00:92	CogentData             # COGENT DATA TECHNOLOGIES
00:00:93	Proteon                # PROTEON INC.
00:00:94	AsanteTech             # ASANTE TECHNOLOGIES
00:00:95	SonyTektro             # SONY TEKTRONIX CORP.
00:00:96	MarconiEle             # MARCONI ELECTRONICS LTD.
00:00:97	Epoch                  # EPOCH SYSTEMS
00:00:98	Crosscomm              # CROSSCOMM CORPORATION
00:00:99	Mtx                    # MTX, INC.
00:00:9A	RcComputer             # RC COMPUTER A/S
00:00:9B	Informatio             # INFORMATION INTERNATIONAL, INC
00:00:9C	RolmMil-Sp             # ROLM MIL-SPEC COMPUTERS
00:00:9D	LocusCompu             # LOCUS COMPUTING CORPORATION
00:00:9E	MarliSA                # MARLI S.A.
00:00:9F	AmeristarT             # AMERISTAR TECHNOLOGIES INC.
00:00:A0	SanyoElect             # SANYO Electric Co., Ltd.
00:00:A1	MarquetteE             # MARQUETTE ELECTRIC CO.
00:00:A2	BayNetwork             # BAY NETWORKS
00:00:A3	NAT
00:00:A4	AcornCompu             # ACORN COMPUTERS LIMITED
00:00:A5	CSC
00:00:A6	NetworkGen             # NETWORK GENERAL CORPORATION
00:00:A7	NCD
00:00:A8	StratusCom             # STRATUS COMPUTER INC.
00:00:A9	NetSys		# Network Systems
00:00:AA	Xerox                  # XEROX CORPORATION
00:00:AB	LogicModel             # LOGIC MODELING CORPORATION
00:00:AC	ConwareCom             # CONWARE COMPUTER CONSULTING
00:00:AD	BrukerInst             # BRUKER INSTRUMENTS INC.
00:00:AE	DassaultEl             # DASSAULT ELECTRONIQUE
00:00:AF	NuclearDat             # NUCLEAR DATA INSTRUMENTATION
00:00:B0	Rnd-RadNet             # RND-RAD NETWORK DEVICES
00:00:B1	AlphaMicro             # ALPHA MICROSYSTEMS INC.
00:00:B2	Televideo              # TELEVIDEO SYSTEMS, INC.
00:00:B3	Cimlinc                # CIMLINC INCORPORATED
00:00:B4	EdimaxComp             # EDIMAX COMPUTER COMPANY
00:00:B5	Datability             # DATABILITY SOFTWARE SYS. INC.
00:00:B6	Micro-Mati             # MICRO-MATIC RESEARCH
00:00:B7	DoveComput             # DOVE COMPUTER CORPORATION
00:00:B8	Seikosha               # SEIKOSHA CO., LTD.
00:00:B9	McdonnellD             # MCDONNELL DOUGLAS COMPUTER SYS
00:00:BA	Siig                   # SIIG, INC.
00:00:BB	Tri-Data
00:00:BC	Allen-Brad             # ALLEN-BRADLEY CO. INC.
00:00:BD	Mitsubishi             # MITSUBISHI CABLE COMPANY
00:00:BE	NtiGroup               # THE NTI GROUP
00:00:BF	SymmetricC             # SYMMETRIC COMPUTER SYSTEMS
00:00:C0	WesternDig             # WESTERN DIGITAL CORPORATION
00:00:C1	Madge                  # Madge Ltd.
00:00:C2	Informatio             # INFORMATION PRESENTATION TECH.
00:00:C3	HarrisComp             # HARRIS CORP COMPUTER SYS DIV
00:00:C4	WatersDivO             # WATERS DIV. OF MILLIPORE
00:00:C5	FarallonCo             # FARALLON COMPUTING/NETOPIA
00:00:C6	Eon                    # EON SYSTEMS
00:00:C7	Arix                   # ARIX CORPORATION
00:00:C8	AltosCompu             # ALTOS COMPUTER SYSTEMS
00:00:C9	Emulex                 # EMULEX CORPORATION
00:00:CA	ArrisInter             # ARRIS International
00:00:CB	Compu-Shac             # COMPU-SHACK ELECTRONIC GMBH
00:00:CC	Densan                 # DENSAN CO., LTD.
00:00:CD	AlliedTele             # Allied Telesyn Research Ltd.
00:00:CE	Megadata               # MEGADATA CORP.
00:00:CF	HayesMicro             # HAYES MICROCOMPUTER PRODUCTS
00:00:D0	DevelconEl             # DEVELCON ELECTRONICS LTD.
00:00:D1	Adaptec                # ADAPTEC INCORPORATED
00:00:D2	Sbe                    # SBE, INC.
00:00:D3	WangLabora             # WANG LABORATORIES INC.
00:00:D4	PureData               # PURE DATA LTD.
00:00:D5	Micrognosi             # MICROGNOSIS INTERNATIONAL
00:00:D6	PunchLineH             # PUNCH LINE HOLDING
00:00:D7	DartmouthC             # DARTMOUTH COLLEGE
00:00:D8	Novell                 # NOVELL, INC.
00:00:D9	NipponTele             # NIPPON TELEGRAPH & TELEPHONE
00:00:DA	Atex
00:00:DB	BritishTel             # BRITISH TELECOMMUNICATIONS PLC
00:00:DC	HayesMicro             # HAYES MICROCOMPUTER PRODUCTS
00:00:DD	Gould
00:00:DE	Unigraph
00:00:DF	BellHowell             # BELL & HOWELL PUB SYS DIV
00:00:E0	Quadram                # QUADRAM CORP.
00:00:E1	Hitachi
00:00:E2	AcerTechno             # ACER TECHNOLOGIES CORP.
00:00:E3	Integrated             # INTEGRATED MICRO PRODUCTS LTD
00:00:E4	In2GroupeI             # IN2 GROUPE INTERTECHNIQUE
00:00:E5	Sigmex                 # SIGMEX LTD.
00:00:E6	AptorProdu             # APTOR PRODUITS DE COMM INDUST
00:00:E7	StarGateTe             # STAR GATE TECHNOLOGIES
00:00:E8	AcctonTech             # ACCTON TECHNOLOGY CORP.
00:00:E9	Isicad                 # ISICAD, INC.
00:00:EA	Upnod                  # UPNOD AB
00:00:EB	Matsushita             # MATSUSHITA COMM. IND. CO. LTD.
00:00:EC	Microproce             # MICROPROCESS
00:00:ED	April
00:00:EE	NetworkDes             # NETWORK DESIGNERS, LTD.
00:00:EF	Kti
00:00:F0	SamsungEle             # SAMSUNG ELECTRONICS CO., LTD.
00:00:F1	MagnaCompu             # MAGNA COMPUTER CORPORATION
00:00:F2	SpiderComm             # SPIDER COMMUNICATIONS
00:00:F3	GandalfDat             # GANDALF DATA LIMITED
00:00:F4	AlliedTele             # ALLIED TELESYN INTERNATIONAL
00:00:F5	DiamondSal             # DIAMOND SALES LIMITED
00:00:F6	Madge
00:00:F7	YouthKeepE             # YOUTH KEEP ENTERPRISE CO LTD
00:00:F8	DigitalEqu             # DIGITAL EQUIPMENT CORPORATION
00:00:F9	Quotron                # QUOTRON SYSTEMS INC.
00:00:FA	MicrosageC             # MICROSAGE COMPUTER SYSTEMS INC
00:00:FB	RechnerZur             # RECHNER ZUR KOMMUNIKATION
00:00:FC	Meiko
00:00:FD	HighLevelH             # HIGH LEVEL HARDWARE
00:00:FE	AnnapolisM             # ANNAPOLIS MICRO SYSTEMS
00:00:FF	CamtecElec             # CAMTEC ELECTRONICS LTD.
00:01:00	EquipTrans             # EQUIP'TRANS
00:01:01	Private
00:01:02	3com                   # 3COM CORPORATION
00:01:03	3com                   # 3COM CORPORATION
00:01:04	Dvico                  # DVICO Co., Ltd.
00:01:05	Beckhoff               # BECKHOFF GmbH
00:01:06	TewsDatent             # Tews Datentechnik GmbH
00:01:07	Leiser                 # Leiser GmbH
00:01:08	AvlabTechn             # AVLAB Technology, Inc.
00:01:09	NaganoJapa             # Nagano Japan Radio Co., Ltd.
00:01:0A	CisTechnol             # CIS TECHNOLOGY INC.
00:01:0B	SpaceCyber             # Space CyberLink, Inc.
00:01:0C	SystemTalk             # System Talks Inc.
00:01:0D	Coreco                 # CORECO, INC.
00:01:0E	Bri-LinkTe             # Bri-Link Technologies Co., Ltd
00:01:0F	Mcdata                 # McDATA Corporation
00:01:10	GothamNetw             # Gotham Networks
00:01:11	Idigm                  # iDigm Inc.
00:01:12	SharkMulti             # Shark Multimedia Inc.
00:01:13	Olympus                # OLYMPUS CORPORATION
00:01:14	KandaTsush             # KANDA TSUSHIN KOGYO CO., LTD.
00:01:15	Extratech              # EXTRATECH CORPORATION
00:01:16	NetspectTe             # Netspect Technologies, Inc.
00:01:17	Canal+                 # CANAL +
00:01:18	EzDigital              # EZ Digital Co., Ltd.
00:01:19	RtunetAust             # RTUnet (Australia)
00:01:1A	EehDatalin             # EEH DataLink GmbH
00:01:1B	UnizoneTec             # Unizone Technologies, Inc.
00:01:1C	UniversalT             # Universal Talkware Corporation
00:01:1D	Centillium             # Centillium Communications
00:01:1E	PrecidiaTe             # Precidia Technologies, Inc.
00:01:1F	RcNetworks             # RC Networks, Inc.
00:01:20	Oscilloqua             # OSCILLOQUARTZ S.A.
00:01:21	Watchguard             # Watchguard Technologies, Inc.
00:01:22	TrendCommu             # Trend Communications, Ltd.
00:01:23	DigitalEle             # DIGITAL ELECTRONICS CORP.
00:01:24	Acer                   # Acer Incorporated
00:01:25	YaesuMusen             # YAESU MUSEN CO., LTD.
00:01:26	PacLabs                # PAC Labs
00:01:27	OpenNetwor             # OPEN Networks Pty Ltd
00:01:28	Enjoyweb               # EnjoyWeb, Inc.
00:01:29	Dfi                    # DFI Inc.
00:01:2A	Telematica             # Telematica Sistems Inteligente
00:01:2B	Telenet                # TELENET Co., Ltd.
00:01:2C	AravoxTech             # Aravox Technologies, Inc.
00:01:2D	KomodoTech             # Komodo Technology
00:01:2E	PcPartner              # PC Partner Ltd.
00:01:2F	TwinheadIn             # Twinhead International Corp
00:01:30	ExtremeNet             # Extreme Networks
00:01:31	Detection              # Detection Systems, Inc.
00:01:32	Dranetz-Bm             # Dranetz - BMI
00:01:33	KyowaElect             # KYOWA Electronic Instruments C
00:01:34	SigPositec             # SIG Positec Systems AG
00:01:35	Kdc                    # KDC Corp.
00:01:36	CybertanTe             # CyberTAN Technology, Inc.
00:01:37	ItFarm                 # IT Farm Corporation
00:01:38	XaviTechno             # XAVi Technologies Corp.
00:01:39	PointMulti             # Point Multimedia Systems
00:01:3A	ShelcadCom             # SHELCAD COMMUNICATIONS, LTD.
00:01:3B	Bna                    # BNA SYSTEMS
00:01:3C	Tiw                    # TIW SYSTEMS
00:01:3D	Riscstatio             # RiscStation Ltd.
00:01:3E	AscomTatec             # Ascom Tateco AB
00:01:3F	NeighborWo             # Neighbor World Co., Ltd.
00:01:40	Sendtek                # Sendtek Corporation
00:01:41	CablePrint             # CABLE PRINT
00:01:42	Cisco                  # Cisco Systems, Inc.
00:01:43	Cisco                  # Cisco Systems, Inc.
00:01:44	Emc                    # EMC Corporation
00:01:45	Winsystems             # WINSYSTEMS, INC.
00:01:46	TescoContr             # Tesco Controls, Inc.
00:01:47	ZhoneTechn             # Zhone Technologies
00:01:48	X-Traweb               # X-traWeb Inc.
00:01:49	TDTTransfe             # T.D.T. Transfer Data Test GmbH
00:01:4A	Sony                   # Sony Corporation
00:01:4B	EnnovateNe             # Ennovate Networks, Inc.
00:01:4C	BerkeleyPr             # Berkeley Process Control
00:01:4D	ShinKinEnt             # Shin Kin Enterprises Co., Ltd
00:01:4E	WinEnterpr             # WIN Enterprises, Inc.
00:01:4F	Adtran                 # ADTRAN INC
00:01:50	GilatCommu             # GILAT COMMUNICATIONS, LTD.
00:01:51	EnsembleCo             # Ensemble Communications
00:01:52	Chromatek              # CHROMATEK INC.
00:01:53	ArchtekTel             # ARCHTEK TELECOM CORPORATION
00:01:54	G3m                    # G3M Corporation
00:01:55	PromiseTec             # Promise Technology, Inc.
00:01:56	Firewiredi             # FIREWIREDIRECT.COM, INC.
00:01:57	Syswave                # SYSWAVE CO., LTD
00:01:58	ElectroInd             # Electro Industries/Gauge Tech
00:01:59	S1                     # S1 Corporation
00:01:5A	DigitalVid             # Digital Video Broadcasting
00:01:5B	ItaltelSPA             # ITALTEL S.p.A/RF-UP-I
00:01:5C	Cadant                 # CADANT INC.
00:01:5D	SunMicrosy             # Sun Microsystems, Inc
00:01:5E	BestTechno             # BEST TECHNOLOGY CO., LTD.
00:01:5F	DigitalDes             # DIGITAL DESIGN GmbH
00:01:60	Elmex                  # ELMEX Co., LTD.
00:01:61	MetaMachin             # Meta Machine Technology
00:01:62	CygnetTech             # Cygnet Technologies, Inc.
00:01:63	Cisco                  # Cisco Systems, Inc.
00:01:64	Cisco                  # Cisco Systems, Inc.
00:01:65	Airswitch              # AirSwitch Corporation
00:01:66	TcGroup                # TC GROUP A/S
00:01:67	HiokiEE                # HIOKI E.E. CORPORATION
00:01:68	Vitana                 # VITANA CORPORATION
00:01:69	CelestixNe             # Celestix Networks Pte Ltd.
00:01:6A	Alitec
00:01:6B	Lightchip              # LightChip, Inc.
00:01:6C	Foxconn
00:01:6D	Carriercom             # CarrierComm Inc.
00:01:6E	Conklin                # Conklin Corporation
00:01:6F	HaitaiElec             # HAITAI ELECTRONICS CO., LTD.
00:01:70	EseEmbedde             # ESE Embedded System Engineer'g
00:01:71	AlliedData             # Allied Data Technologies
00:01:72	Technoland             # TechnoLand Co., LTD.
00:01:73	Amcc
00:01:74	Cyberoptic             # CyberOptics Corporation
00:01:75	RadiantCom             # Radiant Communications Corp.
00:01:76	OrientSilv             # Orient Silver Enterprises
00:01:77	Edsl
00:01:78	Margi                  # MARGI Systems, Inc.
00:01:79	WirelessTe             # WIRELESS TECHNOLOGY, INC.
00:01:7A	ChengduMai             # Chengdu Maipu Electric Industrial Co., Ltd.
00:01:7B	Heidelberg             # Heidelberger Druckmaschinen AG
00:01:7C	Ag-E                   # AG-E GmbH
00:01:7D	Thermoques             # ThermoQuest
00:01:7E	AdtekSyste             # ADTEK System Science Co., Ltd.
00:01:7F	Experience             # Experience Music Project
00:01:80	Aopen                  # AOpen, Inc.
00:01:81	NortelNetw             # Nortel Networks
00:01:82	DicaTechno             # DICA TECHNOLOGIES AG
00:01:83	AniteTelec             # ANITE TELECOMS
00:01:84	SiebMeyer              # SIEB & MEYER AG
00:01:85	Aloka                  # Aloka Co., Ltd.
00:01:86	UweDisch               # Uwe Disch
00:01:87	I2se                   # i2SE GmbH
00:01:88	LxcoTechno             # LXCO Technologies ag
00:01:89	Refraction             # Refraction Technology, Inc.
00:01:8A	RoiCompute             # ROI COMPUTER AG
00:01:8B	Netlinks               # NetLinks Co., Ltd.
00:01:8C	MegaVision             # Mega Vision
00:01:8D	AudesiTech             # AudeSi Technologies
00:01:8E	Logitec                # Logitec Corporation
00:01:8F	Kenetec                # Kenetec, Inc.
00:01:90	Smk-M
00:01:91	SyredData              # SYRED Data Systems
00:01:92	TexasDigit             # Texas Digital Systems
00:01:93	HanbyulTel             # Hanbyul Telecom Co., Ltd.
00:01:94	CapitalEqu             # Capital Equipment Corporation
00:01:95	SenaTechno             # Sena Technologies, Inc.
00:01:96	Cisco                  # Cisco Systems, Inc.
00:01:97	Cisco                  # Cisco Systems, Inc.
00:01:98	DarimVisio             # Darim Vision
00:01:99	HeiseiElec             # HeiSei Electronics
00:01:9A	Leunig                 # LEUNIG GmbH
00:01:9B	KyotoMicro             # Kyoto Microcomputer Co., Ltd.
00:01:9C	JdsUniphas             # JDS Uniphase Inc.
00:01:9D	E-Control              # E-Control Systems, Inc.
00:01:9E	EssTechnol             # ESS Technology, Inc.
00:01:9F	PhonexBroa             # Phonex Broadband
00:01:A0	Infinilink             # Infinilink Corporation
00:01:A1	Mag-Tek                # Mag-Tek, Inc.
00:01:A2	Logical                # Logical Co., Ltd.
00:01:A3	GenesysLog             # GENESYS LOGIC, INC.
00:01:A4	Microlink              # Microlink Corporation
00:01:A5	Nextcomm               # Nextcomm, Inc.
00:01:A6	Scientific             # Scientific-Atlanta Arcodan A/S
00:01:A7	UnexTechno             # UNEX TECHNOLOGY CORPORATION
00:01:A8	WelltechCo             # Welltech Computer Co., Ltd.
00:01:A9	Bmw                    # BMW AG
00:01:AA	AirspanCom             # Airspan Communications, Ltd.
00:01:AB	MainStreet             # Main Street Networks
00:01:AC	SitaraNetw             # Sitara Networks, Inc.
00:01:AD	CoachMaste             # Coach Master International  d.b.a. CMI Worldwide, Inc.
00:01:AE	TrexEnterp             # Trex Enterprises
00:01:AF	MotorolaCo             # Motorola Computer Group
00:01:B0	FulltekTec             # Fulltek Technology Co., Ltd.
00:01:B1	GeneralBan             # General Bandwidth
00:01:B2	DigitalPro             # Digital Processing Systems, Inc.
00:01:B3	PrecisionE             # Precision Electronic Manufacturing
00:01:B4	Wayport                # Wayport, Inc.
00:01:B5	TurinNetwo             # Turin Networks, Inc.
00:01:B6	SaejinT&M              # SAEJIN T&M Co., Ltd.
00:01:B7	Centos                 # Centos, Inc.
00:01:B8	Netsensity             # Netsensity, Inc.
00:01:B9	SkfConditi             # SKF Condition Monitoring
00:01:BA	Ic-Net                 # IC-Net, Inc.
00:01:BB	Frequentis
00:01:BC	Brains                 # Brains Corporation
00:01:BD	PetersonEl             # Peterson Electro-Musical Products, Inc.
00:01:BE	Gigalink               # Gigalink Co., Ltd.
00:01:BF	Teleforce              # Teleforce Co., Ltd.
00:01:C0	Compulab               # CompuLab, Ltd.
00:01:C1	VitesseSem             # Vitesse Semiconductor Corporation
00:01:C2	ArkResearc             # ARK Research Corp.
00:01:C3	Acromag                # Acromag, Inc.
00:01:C4	Neowave                # NeoWave, Inc.
00:01:C5	SimplerNet             # Simpler Networks
00:01:C6	QuarryTech             # Quarry Technologies
00:01:C7	Cisco                  # Cisco Systems, Inc.
00:01:C8	ThomasConr             # THOMAS CONRAD CORP.
00:01:C9	Cisco                  # Cisco Systems, Inc.
00:01:CA	GeocastNet             # Geocast Network Systems, Inc.
00:01:CB	Evr
00:01:CC	JapanTotal             # Japan Total Design Communication Co., Ltd.
00:01:CD	Artem
00:01:CE	CustomMicr             # Custom Micro Products, Ltd.
00:01:CF	AlphaDataP             # Alpha Data Parallel Systems, Ltd.
00:01:D0	Vitalpoint             # VitalPoint, Inc.
00:01:D1	ConetCommu             # CoNet Communications, Inc.
00:01:D2	MacpowerPe             # MacPower Peripherals, Ltd.
00:01:D3	Paxcomm                # PAXCOMM, Inc.
00:01:D4	LeisureTim             # Leisure Time, Inc.
00:01:D5	HaedongInf             # HAEDONG INFO & COMM CO., LTD
00:01:D6	ManRolandD             # MAN Roland Druckmaschinen AG
00:01:D7	F5Networks             # F5 Networks, Inc.
00:01:D8	Teltronics             # Teltronics, Inc.
00:01:D9	Sigma                  # Sigma, Inc.
00:01:DA	Wincomm                # WINCOMM Corporation
00:01:DB	FreecomTec             # Freecom Technologies GmbH
00:01:DC	Activetelc             # Activetelco
00:01:DD	AvailNetwo             # Avail Networks
00:01:DE	Trango                 # Trango Systems, Inc.
00:01:DF	IsdnCommun             # ISDN Communications, Ltd.
00:01:E0	Fast                   # Fast Systems, Inc.
00:01:E1	KinpoElect             # Kinpo Electronics, Inc.
00:01:E2	AndoElectr             # Ando Electric Corporation
00:01:E3	Siemens                # Siemens AG
00:01:E4	Sitera                 # Sitera, Inc.
00:01:E5	Supernet               # Supernet, Inc.
00:01:E6	Hewlett-Pa             # Hewlett-Packard Company
00:01:E7	Hewlett-Pa             # Hewlett-Packard Company
00:01:E8	Force10Net             # Force10 Networks, Inc.
00:01:E9	LittonMari             # Litton Marine Systems B.V.
00:01:EA	Cirilium               # Cirilium Corp.
00:01:EB	C-Com                  # C-COM Corporation
00:01:EC	EricssonGr             # Ericsson Group
00:01:ED	Seta                   # SETA Corp.
00:01:EE	ComtrolEur             # Comtrol Europe, Ltd.
00:01:EF	CamtelTech             # Camtel Technology Corp.
00:01:F0	Tridium                # Tridium, Inc.
00:01:F1	Innovative             # Innovative Concepts, Inc.
00:01:F2	MarkOfUnic             # Mark of the Unicorn, Inc.
00:01:F3	Qps                    # QPS, Inc.
00:01:F4	EnterasysN             # Enterasys Networks
00:01:F5	ErimSA                 # ERIM S.A.
00:01:F6	Associatio             # Association of Musical Electronics Industry
00:01:F7	ImageDispl             # Image Display Systems, Inc.
00:01:F8	Adherent               # Adherent Systems, Ltd.
00:01:F9	Teraglobal             # TeraGlobal Communications Corp.
00:01:FA	Compaq
00:01:FB	DotopTechn             # DoTop Technology, Inc.
00:01:FC	Keyence                # Keyence Corporation
00:01:FD	DigitalVoi             # Digital Voice Systems, Inc.
00:01:FE	DigitalEqu             # DIGITAL EQUIPMENT CORPORATION
00:01:FF	DataDirect             # Data Direct Networks, Inc.
00:02:00	NetSys                 # Net & Sys Co., Ltd.
00:02:01	IfmElectro             # IFM Electronic gmbh
00:02:02	AminoCommu             # Amino Communications, Ltd.
00:02:03	WoonsangTe             # Woonsang Telecom, Inc.
00:02:04	Novell
00:02:05	HitachiDen             # Hitachi Denshi, Ltd.
00:02:06	TelitalR&D             # Telital R&D Denmark A/S
00:02:07	Visionglob             # VisionGlobal Network Corp.
00:02:08	UnifyNetwo             # Unify Networks, Inc.
00:02:09	ShenzhenSe             # Shenzhen SED Information Technology Co., Ltd.
00:02:0A	GefranSpa              # Gefran Spa
00:02:0B	NativeNetw             # Native Networks, Inc.
00:02:0C	Metro-Opti             # Metro-Optix
00:02:0D	MicronpcCo             # Micronpc.com
00:02:0E	LaurelNetw             # Laurel Networks, Inc.
00:02:0F	Aatr
00:02:10	Fenecom
00:02:11	NatureWorl             # Nature Worldwide Technology Corp.
00:02:12	Sierracom
00:02:13	SDEL                   # S.D.E.L.
00:02:14	Dtvro
00:02:15	CotasCompu             # Cotas Computer Technology A/B
00:02:16	Cisco                  # Cisco Systems, Inc.
00:02:17	Cisco                  # Cisco Systems, Inc.
00:02:18	AdvancedSc             # Advanced Scientific Corp
00:02:19	ParalonTec             # Paralon Technologies
00:02:1A	ZumaNetwor             # Zuma Networks
00:02:1B	Kollmorgen             # Kollmorgen-Servotronix
00:02:1C	NetworkEle             # Network Elements, Inc.
00:02:1D	DataGenera             # Data General Communication Ltd.
00:02:1E	SimtelSRL              # SIMTEL S.R.L.
00:02:1F	Aculab                 # Aculab PLC
00:02:20	CanonAptex             # Canon Aptex, Inc.
00:02:21	DspApplica             # DSP Application, Ltd.
00:02:22	Chromisys              # Chromisys, Inc.
00:02:23	Clicktv
00:02:24	C-Cor
00:02:25	CertusTech             # Certus Technology, Inc.
00:02:26	Xesystems              # XESystems, Inc.
00:02:27	Esd                    # ESD GmbH
00:02:28	Necsom                 # Necsom, Ltd.
00:02:29	Adtec                  # Adtec Corporation
00:02:2A	AsoundElec             # Asound Electronic
00:02:2B	Saxa                   # SAXA, Inc.
00:02:2C	AbbBomem               # ABB Bomem, Inc.
00:02:2D	Agere                  # Agere Systems
00:02:2E	TeacR&D                # TEAC Corp. R& D
00:02:2F	P-Cube                 # P-Cube, Ltd.
00:02:30	IntersoftE             # Intersoft Electronics
00:02:31	Axis
00:02:32	Avision                # Avision, Inc.
00:02:33	MantraComm             # Mantra Communications, Inc.
00:02:34	ImperialTe             # Imperial Technology, Inc.
00:02:35	ParagonNet             # Paragon Networks International
00:02:36	Init                   # INIT GmbH
00:02:37	CosmoResea             # Cosmo Research Corp.
00:02:38	SeromeTech             # Serome Technology, Inc.
00:02:39	Visicom
00:02:3A	ZskStickma             # ZSK Stickmaschinen GmbH
00:02:3B	RedbackNet             # Redback Networks
00:02:3C	CreativeTe             # Creative Technology, Ltd.
00:02:3D	Nuspeed                # NuSpeed, Inc.
00:02:3E	SeltaTelem             # Selta Telematica S.p.a
00:02:3F	CompalElec             # Compal Electronics, Inc.
00:02:40	Seedek                 # Seedek Co., Ltd.
00:02:41	AmerCom                # Amer.com
00:02:42	Videoframe             # Videoframe Systems
00:02:43	Raysis                 # Raysis Co., Ltd.
00:02:44	SurecomTec             # SURECOM Technology Co.
00:02:45	Lampus                 # Lampus Co, Ltd.
00:02:46	All-WinTec             # All-Win Tech Co., Ltd.
00:02:47	GreatDrago             # Great Dragon Information Technology (Group) Co., Ltd.
00:02:48	Pilz                   # Pilz GmbH & Co.
00:02:49	AvivInfoco             # Aviv Infocom Co, Ltd.
00:02:4A	Cisco                  # Cisco Systems, Inc.
00:02:4B	Cisco                  # Cisco Systems, Inc.
00:02:4C	Sibyte                 # SiByte, Inc.
00:02:4D	MannesmanD             # Mannesman Dematic Colby Pty. Ltd.
00:02:4E	DatacardGr             # Datacard Group
00:02:4F	IpmDatacom             # IPM Datacom S.R.L.
00:02:50	GeyserNetw             # Geyser Networks, Inc.
00:02:51	SomaNetwor             # Soma Networks, Inc.
00:02:52	Carrier                # Carrier Corporation
00:02:53	Televideo              # Televideo, Inc.
00:02:54	Worldgate
00:02:55	Ibm                    # IBM Corporation
00:02:56	AlphaProce             # Alpha Processor, Inc.
00:02:57	Microcom               # Microcom Corp.
00:02:58	FlyingPack             # Flying Packets Communications
00:02:59	TsannKuenC             # Tsann Kuen China (Shanghai)Enterprise Co., Ltd. IT Group
00:02:5A	CatenaNetw             # Catena Networks
00:02:5B	CambridgeS             # Cambridge Silicon Radio
00:02:5C	SciKunshan             # SCI Systems (Kunshan) Co., Ltd.
00:02:5D	CalixNetwo             # Calix Networks
00:02:5E	HighTechno             # High Technology Ltd
00:02:5F	NortelNetw             # Nortel Networks
00:02:60	AccordionN             # Accordion Networks, Inc.
00:02:61	I3MicroTec             # i3 Micro Technology AB
00:02:62	SoyoGroupS             # Soyo Group Soyo Com Tech Co., Ltd
00:02:63	UpsManufac             # UPS Manufacturing SRL
00:02:64	AudiorampC             # AudioRamp.com
00:02:65	Virditech              # Virditech Co. Ltd.
00:02:66	Thermalogi             # Thermalogic Corporation
00:02:67	NodeRunner             # NODE RUNNER, INC.
00:02:68	HarrisGove             # Harris Government Communications
00:02:69	Nadatel                # Nadatel Co., Ltd
00:02:6A	CocessTele             # Cocess Telecom Co., Ltd.
00:02:6B	BcmCompute             # BCM Computers Co., Ltd.
00:02:6C	PhilipsCft             # Philips CFT
00:02:6D	AdeptTelec             # Adept Telecom
00:02:6E	NegenAcces             # NeGeN Access, Inc.
00:02:6F	SenaoInter             # Senao International Co., Ltd.
00:02:70	Crewave                # Crewave Co., Ltd.
00:02:71	VpacketCom             # Vpacket Communications
00:02:72	Cc&CTechno             # CC&C Technologies, Inc.
00:02:73	CoriolisNe             # Coriolis Networks
00:02:74	TommyTechn             # Tommy Technologies Corp.
00:02:75	SmartTechn             # SMART Technologies, Inc.
00:02:76	PrimaxElec             # Primax Electronics Ltd.
00:02:77	CashSystem             # Cash Systemes Industrie
00:02:78	SamsungEle             # Samsung Electro-Mechanics Co., Ltd.
00:02:79	ControlApp             # Control Applications, Ltd.
00:02:7A	IoiTechnol             # IOI Technology Corporation
00:02:7B	AmplifyNet             # Amplify Net, Inc.
00:02:7C	Trilithic              # Trilithic, Inc.
00:02:7D	Cisco                  # Cisco Systems, Inc.
00:02:7E	Cisco                  # Cisco Systems, Inc.
00:02:7F	Ask-Techno             # ask-technologies.com
00:02:80	MuNet                  # Mu Net, Inc.
00:02:81	Madge                  # Madge Ltd.
00:02:82	Viaclix                # ViaClix, Inc.
00:02:83	SpectrumCo             # Spectrum Controls, Inc.
00:02:84	ArevaT&D               # AREVA T&D
00:02:85	Riverstone             # Riverstone Networks
00:02:86	OccamNetwo             # Occam Networks
00:02:87	Adapcom
00:02:88	GlobalVill             # GLOBAL VILLAGE COMMUNICATION
00:02:89	DneTechnol             # DNE Technologies
00:02:8A	AmbitMicro             # Ambit Microsystems Corporation
00:02:8B	VdslOy                 # VDSL Systems OY
00:02:8C	Micrel-Syn             # Micrel-Synergy Semiconductor
00:02:8D	MovitaTech             # Movita Technologies, Inc.
00:02:8E	Rapid5Netw             # Rapid 5 Networks, Inc.
00:02:8F	Globetek               # Globetek, Inc.
00:02:90	Woorigisoo             # Woorigisool, Inc.
00:02:91	OpenNetwor             # Open Network Co., Ltd.
00:02:92	LogicInnov             # Logic Innovations, Inc.
00:02:93	SolidData              # Solid Data Systems
00:02:94	TokyoSokus             # Tokyo Sokushin Co., Ltd.
00:02:95	IpAccess               # IP.Access Limited
00:02:96	Lectron                # Lectron Co,. Ltd.
00:02:97	C-CorNet               # C-COR.net
00:02:98	Broadframe             # Broadframe Corporation
00:02:99	Apex                   # Apex, Inc.
00:02:9A	StorageApp             # Storage Apps
00:02:9B	KreatelCom             # Kreatel Communications AB
00:02:9C	3com
00:02:9D	Merix                  # Merix Corp.
00:02:9E	Informatio             # Information Equipment Co., Ltd.
00:02:9F	L-3Communi             # L-3 Communication Aviation Recorders
00:02:A0	Flatstack              # Flatstack Ltd.
00:02:A1	WorldWideP             # World Wide Packets
00:02:A2	Hilscher               # Hilscher GmbH
00:02:A3	AbbPowerAu             # ABB Power Automation
00:02:A4	AddpacTech             # AddPac Technology Co., Ltd.
00:02:A5	CompaqComp             # Compaq Computer Corporation
00:02:A6	Effinet                # Effinet Systems Co., Ltd.
00:02:A7	VivaceNetw             # Vivace Networks
00:02:A8	AirLinkTec             # Air Link Technology
00:02:A9	RacomSRO               # RACOM, s.r.o.
00:02:AA	Plcom                  # PLcom Co., Ltd.
00:02:AB	CtcUnionTe             # CTC Union Technologies Co., Ltd.
00:02:AC	3parData               # 3PAR data
00:02:AD	PentaxCorp             # Pentax Corpotation
00:02:AE	ScannexEle             # Scannex Electronics Ltd.
00:02:AF	TelecruzTe             # TeleCruz Technology, Inc.
00:02:B0	HokubuComm             # Hokubu Communication & Industrial Co., Ltd.
00:02:B1	Anritsu                # Anritsu, Ltd.
00:02:B2	Cablevisio             # Cablevision
00:02:B3	Intel                  # Intel Corporation
00:02:B4	Daphne
00:02:B5	Avnet                  # Avnet, Inc.
00:02:B6	AcrosserTe             # Acrosser Technology Co., Ltd.
00:02:B7	WatanabeEl             # Watanabe Electric Industry Co., Ltd.
00:02:B8	WhiKonsult             # WHI KONSULT AB
00:02:B9	Cisco                  # Cisco Systems, Inc.
00:02:BA	Cisco                  # Cisco Systems, Inc.
00:02:BB	Continuous             # Continuous Computing
00:02:BC	Lvl7                   # LVL 7 Systems, Inc.
00:02:BD	Bionet                 # Bionet Co., Ltd.
00:02:BE	TotsuEngin             # Totsu Engineering, Inc.
00:02:BF	Dotrocket              # dotRocket, Inc.
00:02:C0	BencentTze             # Bencent Tzeng Industry Co., Ltd.
00:02:C1	Innovative             # Innovative Electronic Designs, Inc.
00:02:C2	NetVisionT             # Net Vision Telecom
00:02:C3	Arelnet                # Arelnet Ltd.
00:02:C4	VectorInte             # Vector International BUBA
00:02:C5	EvertzMicr             # Evertz Microsystems Ltd.
00:02:C6	DataTrackT             # Data Track Technology PLC
00:02:C7	AlpsElectr             # ALPS ELECTRIC Co., Ltd.
00:02:C8	TechnocomC             # Technocom Communications Technology (pte) Ltd
00:02:C9	MellanoxTe             # Mellanox Technologies
00:02:CA	Endpoints              # EndPoints, Inc.
00:02:CB	Tristate               # TriState Ltd.
00:02:CC	MCCI                   # M.C.C.I
00:02:CD	Teledream              # TeleDream, Inc.
00:02:CE	Foxjet                 # FoxJet, Inc.
00:02:CF	ZygateComm             # ZyGate Communications, Inc.
00:02:D0	Comdial                # Comdial Corporation
00:02:D1	Vivotek                # Vivotek, Inc.
00:02:D2	Workstatio             # Workstation AG
00:02:D3	Netbotz                # NetBotz, Inc.
00:02:D4	PdaPeriphe             # PDA Peripherals, Inc.
00:02:D5	Acr
00:02:D6	Nice                   # NICE Systems
00:02:D7	Empeg                  # EMPEG Ltd
00:02:D8	BrecisComm             # BRECIS Communications Corporation
00:02:D9	ReliableCo             # Reliable Controls
00:02:DA	ExioCommun             # ExiO Communications, Inc.
00:02:DB	Netsec
00:02:DC	FujitsuGen             # Fujitsu General Limited
00:02:DD	BromaxComm             # Bromax Communications, Ltd.
00:02:DE	Astrodesig             # Astrodesign, Inc.
00:02:DF	NetCom                 # Net Com Systems, Inc.
00:02:E0	Etas                   # ETAS GmbH
00:02:E1	Integrated             # Integrated Network Corporation
00:02:E2	NdcInfared             # NDC Infared Engineering
00:02:E3	Lite-OnCom             # LITE-ON Communications, Inc.
00:02:E4	JcHyun                 # JC HYUN Systems, Inc.
00:02:E5	Timeware               # Timeware Ltd.
00:02:E6	GouldInstr             # Gould Instrument Systems, Inc.
00:02:E7	Cab                    # CAB GmbH & Co KG
00:02:E8	ED&A                   # E.D.&A.
00:02:E9	CsSystemes             # CS Systemes De Securite - C3S
00:02:EA	FocusEnhan             # Focus Enhancements
00:02:EB	PicoCommun             # Pico Communications
00:02:EC	MaschoffDe             # Maschoff Design Engineering
00:02:ED	DxoTelecom             # DXO Telecom Co., Ltd.
00:02:EE	NokiaDanma             # Nokia Danmark A/S
00:02:EF	CccNetwork             # CCC Network Systems Group Ltd.
00:02:F0	AmeOptimed             # AME Optimedia Technology Co., Ltd.
00:02:F1	Pinetron               # Pinetron Co., Ltd.
00:02:F2	Edevice                # eDevice, Inc.
00:02:F3	MediaServe             # Media Serve Co., Ltd.
00:02:F4	Pctel                  # PCTEL, Inc.
00:02:F5	ViveSynerg             # VIVE Synergies, Inc.
00:02:F6	EquipeComm             # Equipe Communications
00:02:F7	Arm
00:02:F8	SeakrEngin             # SEAKR Engineering, Inc.
00:02:F9	MimosSemic             # Mimos Semiconductor SDN BHD
00:02:FA	DxAntenna              # DX Antenna Co., Ltd.
00:02:FB	BaumullerA             # Baumuller Aulugen-Systemtechnik GmbH
00:02:FC	Cisco                  # Cisco Systems, Inc.
00:02:FD	Cisco                  # Cisco Systems, Inc.
00:02:FE	Viditec                # Viditec, Inc.
00:02:FF	HandanBroa             # Handan BroadInfoCom
00:03:00	Netcontinu             # NetContinuum, Inc.
00:03:01	AvantasNet             # Avantas Networks Corporation
00:03:02	CharlesInd             # Charles Industries, Ltd.
00:03:03	JamaElectr             # JAMA Electronics Co., Ltd.
00:03:04	PacificBro             # Pacific Broadband Communications
00:03:05	SmartNetwo             # Smart Network Devices GmbH
00:03:06	FusionInTe             # Fusion In Tech Co., Ltd.
00:03:07	SecureWork             # Secure Works, Inc.
00:03:08	AmCommunic             # AM Communications, Inc.
00:03:09	TexcelTech             # Texcel Technology PLC
00:03:0A	ArgusTechn             # Argus Technologies
00:03:0B	HunterTech             # Hunter Technology, Inc.
00:03:0C	TelesoftTe             # Telesoft Technologies Ltd.
00:03:0D	UniwillCom             # Uniwill Computer Corp.
00:03:0E	CoreCommun             # Core Communications Co., Ltd.
00:03:0F	DigitalChi             # Digital China (Shanghai) Networks Ltd.
00:03:10	LinkEvolut             # Link Evolution Corp.
00:03:11	MicroTechn             # Micro Technology Co., Ltd.
00:03:12	Tr-Systemt             # TR-Systemtechnik GmbH
00:03:13	AccessMedi             # Access Media SPA
00:03:14	TelewareNe             # Teleware Network Systems
00:03:15	Cidco                  # Cidco Incorporated
00:03:16	NobellComm             # Nobell Communications, Inc.
00:03:17	Merlin                 # Merlin Systems, Inc.
00:03:18	Cyras                  # Cyras Systems, Inc.
00:03:19	Infineon               # Infineon AG
00:03:1A	BeijingBro             # Beijing Broad Telecom Ltd., China
00:03:1B	Cellvision             # Cellvision Systems, Inc.
00:03:1C	SvenskaHar             # Svenska Hardvarufabriken AB
00:03:1D	TaiwanComm             # Taiwan Commate Computer, Inc.
00:03:1E	Optranet               # Optranet, Inc.
00:03:1F	Condev                 # Condev Ltd.
00:03:20	Xpeed                  # Xpeed, Inc.
00:03:21	RecoResear             # Reco Research Co., Ltd.
00:03:22	Idis                   # IDIS Co., Ltd.
00:03:23	CornetTech             # Cornet Technology, Inc.
00:03:24	SanyoMulti             # SANYO Multimedia Tottori Co., Ltd.
00:03:25	ArimaCompu             # Arima Computer Corp.
00:03:26	IwasakiInf             # Iwasaki Information Systems Co., Ltd.
00:03:27	ActL                   # ACT'L
00:03:28	MaceGroup              # Mace Group, Inc.
00:03:29	F3                     # F3, Inc.
00:03:2A	UnidataCom             # UniData Communication Systems, Inc.
00:03:2B	GaiDatenfu             # GAI Datenfunksysteme GmbH
00:03:2C	AbbIndustr             # ABB Industrie AG
00:03:2D	IbaseTechn             # IBASE Technology, Inc.
00:03:2E	ScopeInfor             # Scope Information Management, Ltd.
00:03:2F	GlobalSunT             # Global Sun Technology, Inc.
00:03:30	Imagenics              # Imagenics, Co., Ltd.
00:03:31	Cisco                  # Cisco Systems, Inc.
00:03:32	Cisco                  # Cisco Systems, Inc.
00:03:33	Digitel                # Digitel Co., Ltd.
00:03:34	NewportEle             # Newport Electronics
00:03:35	MiraeTechn             # Mirae Technology
00:03:36	ZetesTechn             # Zetes Technologies
00:03:37	Vaone                  # Vaone, Inc.
00:03:38	OakTechnol             # Oak Technology
00:03:39	Eurologic              # Eurologic Systems, Ltd.
00:03:3A	SiliconWav             # Silicon Wave, Inc.
00:03:3B	TamiTech               # TAMI Tech Co., Ltd.
00:03:3C	Daiden                 # Daiden Co., Ltd.
00:03:3D	IlshinLab              # ILSHin Lab
00:03:3E	TateyamaSy             # Tateyama System Laboratory Co., Ltd.
00:03:3F	BigbandNet             # BigBand Networks, Ltd.
00:03:40	FlowareWir             # Floware Wireless Systems, Ltd.
00:03:41	AxonDigita             # Axon Digital Design
00:03:42	NortelNetw             # Nortel Networks
00:03:43	MartinProf             # Martin Professional A/S
00:03:44	Tietech                # Tietech.Co., Ltd.
00:03:45	RoutrekNet             # Routrek Networks Corporation
00:03:46	HitachiKok             # Hitachi Kokusai Electric, Inc.
00:03:47	Intel                  # Intel Corporation
00:03:48	NorscanIns             # Norscan Instruments, Ltd.
00:03:49	VidicodeDa             # Vidicode Datacommunicatie B.V.
00:03:4A	Rias                   # RIAS Corporation
00:03:4B	NortelNetw             # Nortel Networks
00:03:4C	ShanghaiDi             # Shanghai DigiVision Technology Co., Ltd.
00:03:4D	ChiaroNetw             # Chiaro Networks, Ltd.
00:03:4E	PosData                # Pos Data Company, Ltd.
00:03:4F	Sur-GardSe             # Sur-Gard Security
00:03:50	BticinoSpa             # BTICINO SPA
00:03:51	Diebold                # Diebold, Inc.
00:03:52	ColubrisNe             # Colubris Networks
00:03:53	Mitac                  # Mitac, Inc.
00:03:54	FiberLogic             # Fiber Logic Communications
00:03:55	TerabeamIn             # TeraBeam Internet Systems
00:03:56	WincorNixd             # Wincor Nixdorf GmbH & Co KG
00:03:57	Intervoice             # Intervoice-Brite, Inc.
00:03:58	HanyangDig             # Hanyang Digitech Co., Ltd.
00:03:59	Digitalsis
00:03:5A	Photron                # Photron Limited
00:03:5B	Bridgewave             # BridgeWave Communications
00:03:5C	SaintSong              # Saint Song Corp.
00:03:5D	BosungHi-N             # Bosung Hi-Net Co., Ltd.
00:03:5E	Metropolit             # Metropolitan Area Networks, Inc.
00:03:5F	Prueftechn             # Prueftechnik Condition Monitoring GmbH & Co. KG
00:03:60	PacInterac             # PAC Interactive Technology, Inc.
00:03:61	Widcomm                # Widcomm, Inc.
00:03:62	VodtelComm             # Vodtel Communications, Inc.
00:03:63	Miraesys               # Miraesys Co., Ltd.
00:03:64	ScenixSemi             # Scenix Semiconductor, Inc.
00:03:65	KiraInform             # Kira Information & Communications, Ltd.
00:03:66	AsmPacific             # ASM Pacific Technology
00:03:67	JasmineNet             # Jasmine Networks, Inc.
00:03:68	Embedone               # Embedone Co., Ltd.
00:03:69	NipponAnte             # Nippon Antenna Co., Ltd.
00:03:6A	Mainnet                # Mainnet, Ltd.
00:03:6B	Cisco                  # Cisco Systems, Inc.
00:03:6C	Cisco                  # Cisco Systems, Inc.
00:03:6D	Runtop                 # Runtop, Inc.
00:03:6E	NiconPty               # Nicon Systems (Pty) Limited
00:03:6F	TelseySpa              # Telsey SPA
00:03:70	Nxtv                   # NXTV, Inc.
00:03:71	AcomzNetwo             # Acomz Networks Corp.
00:03:72	Ulan
00:03:73	AselsanAS              # Aselsan A.S
00:03:74	HunterWate             # Hunter Watertech
00:03:75	Netmedia               # NetMedia, Inc.
00:03:76	GraphtecTe             # Graphtec Technology, Inc.
00:03:77	GigabitWir             # Gigabit Wireless
00:03:78	Humax                  # HUMAX Co., Ltd.
00:03:79	ProscendCo             # Proscend Communications, Inc.
00:03:7A	TaiyoYuden             # Taiyo Yuden Co., Ltd.
00:03:7B	IdecIzumi              # IDEC IZUMI Corporation
00:03:7C	CoaxMedia              # Coax Media
00:03:7D	Stellcom
00:03:7E	PortechCom             # PORTech Communications, Inc.
00:03:7F	AtherosCom             # Atheros Communications, Inc.
00:03:80	SshCommuni             # SSH Communications Security Corp.
00:03:81	IngenicoIn             # Ingenico International
00:03:82	A-One                  # A-One Co., Ltd.
00:03:83	MeteraNetw             # Metera Networks, Inc.
00:03:84	Aeta
00:03:85	ActelisNet             # Actelis Networks, Inc.
00:03:86	HoNet                  # Ho Net, Inc.
00:03:87	BlazeNetwo             # Blaze Network Products
00:03:88	FastfameTe             # Fastfame Technology Co., Ltd.
00:03:89	Plantronic             # Plantronics
00:03:8A	AmericaOnl             # America Online, Inc.
00:03:8B	Plus-OneI&             # PLUS-ONE I&T, Inc.
00:03:8C	TotalImpac             # Total Impact
00:03:8D	PcsRevenue             # PCS Revenue Control Systems, Inc.
00:03:8E	Atoga                  # Atoga Systems, Inc.
00:03:8F	Weinschel              # Weinschel Corporation
00:03:90	DigitalVid             # Digital Video Communications, Inc.
00:03:91	AdvancedDi             # Advanced Digital Broadcast, Ltd.
00:03:92	HyundaiTel             # Hyundai Teletek Co., Ltd.
00:03:93	AppleCompu             # Apple Computer, Inc.
00:03:94	ConnectOne             # Connect One
00:03:95	California             # California Amplifier
00:03:96	EzCast                 # EZ Cast Co., Ltd.
00:03:97	Watchfront             # Watchfront Electronics
00:03:98	Wisi
00:03:99	DongjuInfo             # Dongju Informations & Communications Co., Ltd.
00:03:9A	Nsine                  # nSine, Ltd.
00:03:9B	NetchipTec             # NetChip Technology, Inc.
00:03:9C	OptimightC             # OptiMight Communications, Inc.
00:03:9D	Benq                   # BENQ CORPORATION
00:03:9E	TeraSystem             # Tera System Co., Ltd.
00:03:9F	Cisco                  # Cisco Systems, Inc.
00:03:A0	Cisco                  # Cisco Systems, Inc.
00:03:A1	HiperInfor             # HIPER Information & Communication, Inc.
00:03:A2	CatapultCo             # Catapult Communications
00:03:A3	Mavix                  # MAVIX, Ltd.
00:03:A4	DataStorag             # Data Storage and Information Management
00:03:A5	Medea                  # Medea Corporation
00:03:A6	TraxitTech             # Traxit Technology, Inc.
00:03:A7	UnixtarTec             # Unixtar Technology, Inc.
00:03:A8	IdotComput             # IDOT Computers, Inc.
00:03:A9	AxcentMedi             # AXCENT Media AG
00:03:AA	Watlow
00:03:AB	BridgeInfo             # Bridge Information Systems
00:03:AC	FroniusSch             # Fronius Schweissmaschinen
00:03:AD	EmersonEne             # Emerson Energy Systems AB
00:03:AE	AlliedAdva             # Allied Advanced Manufacturing Pte, Ltd.
00:03:AF	ParageaCom             # Paragea Communications
00:03:B0	XsenseTech             # Xsense Technology Corp.
00:03:B1	Hospira                # Hospira Inc.
00:03:B2	Radware
00:03:B3	IaLink                 # IA Link Systems Co., Ltd.
00:03:B4	MacrotekIn             # Macrotek International Corp.
00:03:B5	EntraTechn             # Entra Technology Co.
00:03:B6	Qsi                    # QSI Corporation
00:03:B7	Zaccess                # ZACCESS Systems
00:03:B8	NetkitSolu             # NetKit Solutions, LLC
00:03:B9	HualongTel             # Hualong Telecom Co., Ltd.
00:03:BA	SunMicrosy             # Sun Microsystems
00:03:BB	SignalComm             # Signal Communications Limited
00:03:BC	Cot                    # COT GmbH
00:03:BD	Omnicluste             # OmniCluster Technologies, Inc.
00:03:BE	Netility
00:03:BF	Centerpoin             # Centerpoint Broadband Technologies, Inc.
00:03:C0	Rftnc                  # RFTNC Co., Ltd.
00:03:C1	PacketDyna             # Packet Dynamics Ltd
00:03:C2	SolphoneKK             # Solphone K.K.
00:03:C3	MicronikMu             # Micronik Multimedia
00:03:C4	TomraAsa               # Tomra Systems ASA
00:03:C5	Mobotix                # Mobotix AG
00:03:C6	Icue                   # ICUE Systems, Inc.
00:03:C7	HopfElektr             # hopf Elektronik GmbH
00:03:C8	CmlEmergen             # CML Emergency Services
00:03:C9	Tecom                  # TECOM Co., Ltd.
00:03:CA	Mts                    # MTS Systems Corp.
00:03:CB	NipponDeve             # Nippon Systems Development Co., Ltd.
00:03:CC	MomentumCo             # Momentum Computer, Inc.
00:03:CD	Clovertech             # Clovertech, Inc.
00:03:CE	EtenTechno             # ETEN Technologies, Inc.
00:03:CF	Muxcom                 # Muxcom, Inc.
00:03:D0	Koankeiso              # KOANKEISO Co., Ltd.
00:03:D1	Takaya                 # Takaya Corporation
00:03:D2	Crossbeam              # Crossbeam Systems, Inc.
00:03:D3	InternetEn             # Internet Energy Systems, Inc.
00:03:D4	Alloptic               # Alloptic, Inc.
00:03:D5	AdvancedCo             # Advanced Communications Co., Ltd.
00:03:D6	Radvision              # RADVision, Ltd.
00:03:D7	NextnetWir             # NextNet Wireless, Inc.
00:03:D8	ImpathNetw             # iMPath Networks, Inc.
00:03:D9	SecheronSa             # Secheron SA
00:03:DA	Takamisawa             # Takamisawa Cybernetics Co., Ltd.
00:03:DB	ApogeeElec             # Apogee Electronics Corp.
00:03:DC	LexarMedia             # Lexar Media, Inc.
00:03:DD	Comark                 # Comark Corp.
00:03:DE	OtcWireles             # OTC Wireless
00:03:DF	Desana                 # Desana Systems
00:03:E0	Radioframe             # RadioFrame Networks, Inc.
00:03:E1	WinmateCom             # Winmate Communication, Inc.
00:03:E2	Comspace               # Comspace Corporation
00:03:E3	Cisco                  # Cisco Systems, Inc.
00:03:E4	Cisco                  # Cisco Systems, Inc.
00:03:E5	HermstedtS             # Hermstedt SG
00:03:E6	EntoneTech             # Entone Technologies, Inc.
00:03:E7	Logostek               # Logostek Co. Ltd.
00:03:E8	Wavelength             # Wavelength Digital Limited
00:03:E9	AkaraCanad             # Akara Canada, Inc.
00:03:EA	MegaSystem             # Mega System Technologies, Inc.
00:03:EB	Atrica
00:03:EC	IcgResearc             # ICG Research, Inc.
00:03:ED	ShinkawaEl             # Shinkawa Electric Co., Ltd.
00:03:EE	Mknet                  # MKNet Corporation
00:03:EF	Oneline                # Oneline AG
00:03:F0	RedfernBro             # Redfern Broadband Networks
00:03:F1	CicadaSemi             # Cicada Semiconductor, Inc.
00:03:F2	SenecaNetw             # Seneca Networks
00:03:F3	DazzleMult             # Dazzle Multimedia, Inc.
00:03:F4	Netburner
00:03:F5	Chip2chip
00:03:F6	AllegroNet             # Allegro Networks, Inc.
00:03:F7	Plast-Cont             # Plast-Control GmbH
00:03:F8	SancastleT             # SanCastle Technologies, Inc.
00:03:F9	PleiadesCo             # Pleiades Communications, Inc.
00:03:FA	TimetraNet             # TiMetra Networks
00:03:FB	TokoSeiki              # Toko Seiki Company, Ltd.
00:03:FC	IntertexDa             # Intertex Data AB
00:03:FD	Cisco                  # Cisco Systems, Inc.
00:03:FE	Cisco                  # Cisco Systems, Inc.
00:03:FF	Microsoft              # Microsoft Corporation
00:04:00	LexmarkInt             # LEXMARK INTERNATIONAL, INC.
00:04:01	OsakiElect             # Osaki Electric Co., Ltd.
00:04:02	NexsanTech             # Nexsan Technologies, Ltd.
00:04:03	Nexsi                  # Nexsi Corporation
00:04:04	MakinoMill             # Makino Milling Machine Co., Ltd.
00:04:05	AcnTechnol             # ACN Technologies
00:04:06	FaMetabox              # Fa. Metabox AG
00:04:07	TopconPosi             # Topcon Positioning Systems, Inc.
00:04:08	SankoElect             # Sanko Electronics Co., Ltd.
00:04:09	CratosNetw             # Cratos Networks
00:04:0A	Sage                   # Sage Systems
00:04:0B	3comEurope             # 3com Europe Ltd.
00:04:0C	KannoWorkS             # KANNO Work's Ltd.
00:04:0D	Avaya                  # Avaya, Inc.
00:04:0E	Avm                    # AVM GmbH
00:04:0F	AsusNetwor             # Asus Network Technologies, Inc.
00:04:10	SpinnakerN             # Spinnaker Networks, Inc.
00:04:11	InkraNetwo             # Inkra Networks, Inc.
00:04:12	WavesmithN             # WaveSmith Networks, Inc.
00:04:13	SnomTechno             # SNOM Technology AG
00:04:14	UmezawaMus             # Umezawa Musen Denki Co., Ltd.
00:04:15	Rasteme                # Rasteme Systems Co., Ltd.
00:04:16	ParksComun             # Parks S/A Comunicacoes Digitais
00:04:17	Elau                   # ELAU AG
00:04:18	TeltronicS             # Teltronic S.A.U.
00:04:19	Fibercycle             # Fibercycle Networks, Inc.
00:04:1A	Ines                   # ines GmbH
00:04:1B	DigitalInt             # Digital Interfaces Ltd.
00:04:1C	Ipdialog               # ipDialog, Inc.
00:04:1D	CoregaOfAm             # Corega of America
00:04:1E	ShikokuIns             # Shikoku Instrumentation Co., Ltd.
00:04:1F	SonyComput             # Sony Computer Entertainment, Inc.
00:04:20	SlimDevice             # Slim Devices, Inc.
00:04:21	OcularNetw             # Ocular Networks
00:04:22	GordonKape             # Gordon Kapes, Inc.
00:04:23	Intel                  # Intel Corporation
00:04:24	TmcSRL                 # TMC s.r.l.
00:04:25	Atmel                  # Atmel Corporation
00:04:26	Autosys
00:04:27	Cisco                  # Cisco Systems, Inc.
00:04:28	Cisco                  # Cisco Systems, Inc.
00:04:29	Pixord                 # Pixord Corporation
00:04:2A	WirelessNe             # Wireless Networks, Inc.
00:04:2B	ItAccess               # IT Access Co., Ltd.
00:04:2C	Minet                  # Minet, Inc.
00:04:2D	Sarian                 # Sarian Systems, Ltd.
00:04:2E	NetousTech             # Netous Technologies, Ltd.
00:04:2F	Internatio             # International Communications Products, Inc.
00:04:30	Netgem
00:04:31	Globalstre             # GlobalStreams, Inc.
00:04:32	VoyetraTur             # Voyetra Turtle Beach, Inc.
00:04:33	Cyberboard             # Cyberboard A/S
00:04:34	Accelent               # Accelent Systems, Inc.
00:04:35	ComptekInt             # Comptek International, Inc.
00:04:36	ElansatTec             # ELANsat Technologies, Inc.
00:04:37	PowinInfor             # Powin Information Technology, Inc.
00:04:38	NortelNetw             # Nortel Networks
00:04:39	RoscoEnter             # Rosco Entertainment Technology, Inc.
00:04:3A	Intelligen             # Intelligent Telecommunications, Inc.
00:04:3B	LavaComput             # Lava Computer Mfg., Inc.
00:04:3C	Sonos                  # SONOS Co., Ltd.
00:04:3D	Indel                  # INDEL AG
00:04:3E	Telencomm
00:04:3F	Electronic             # Electronic Systems Technology, Inc.
00:04:40	Cyberpixie             # cyberPIXIE, Inc.
00:04:41	HalfDome               # Half Dome Systems, Inc.
00:04:42	Nact
00:04:43	AgilentTec             # Agilent Technologies, Inc.
00:04:44	WesternMul             # Western Multiplex Corporation
00:04:45	LmsSkalarI             # LMS Skalar Instruments GmbH
00:04:46	Cyzentech              # CYZENTECH Co., Ltd.
00:04:47	Acrowave               # Acrowave Systems Co., Ltd.
00:04:48	PolaroidPr             # Polaroid Professional Imaging
00:04:49	MapletreeN             # Mapletree Networks
00:04:4A	IpolicyNet             # iPolicy Networks, Inc.
00:04:4B	Nvidia
00:04:4C	Jenoptik
00:04:4D	Cisco                  # Cisco Systems, Inc.
00:04:4E	Cisco                  # Cisco Systems, Inc.
00:04:4F	LeukhardtS             # Leukhardt Systemelektronik GmbH
00:04:50	DmdCompute             # DMD Computers SRL
00:04:51	Medrad                 # Medrad, Inc.
00:04:52	Rocketlogi             # RocketLogix, Inc.
00:04:53	Yottayotta             # YottaYotta, Inc.
00:04:54	QuadrigaUk             # Quadriga UK
00:04:55	AntaraNet              # ANTARA.net
00:04:56	PipinghotN             # PipingHot Networks
00:04:57	UniversalA             # Universal Access Technology, Inc.
00:04:58	FusionX                # Fusion X Co., Ltd.
00:04:59	Veristar               # Veristar Corporation
00:04:5A	LinksysGro             # The Linksys Group, Inc.
00:04:5B	TechsanEle             # Techsan Electronics Co., Ltd.
00:04:5C	MobiwavePt             # Mobiwave Pte Ltd
00:04:5D	BekaElektr             # BEKA Elektronik
00:04:5E	PolytraxIn             # PolyTrax Information Technology AG
00:04:5F	EvalueTech             # Evalue Technology, Inc.
00:04:60	KnilinkTec             # Knilink Technology, Inc.
00:04:61	EpoxComput             # EPOX Computer Co., Ltd.
00:04:62	DakosDataC             # DAKOS Data & Communication Co., Ltd.
00:04:63	BoschSecur             # Bosch Security Systems
00:04:64	FantasmaNe             # Fantasma Networks, Inc.
00:04:65	ISTIsdn-Su             # i.s.t isdn-support technik GmbH
00:04:66	Armitel                # ARMITEL Co.
00:04:67	WuhanResea             # Wuhan Research Institute of MII
00:04:68	Vivity                 # Vivity, Inc.
00:04:69	Innocom                # Innocom, Inc.
00:04:6A	NaviniNetw             # Navini Networks
00:04:6B	PalmWirele             # Palm Wireless, Inc.
00:04:6C	CyberTechn             # Cyber Technology Co., Ltd.
00:04:6D	Cisco                  # Cisco Systems, Inc.
00:04:6E	Cisco                  # Cisco Systems, Inc.
00:04:6F	DigitelInd             # Digitel S/A Industria Eletronica
00:04:70	Ipunplugge             # ipUnplugged AB
00:04:71	Iprad
00:04:72	Telelynx               # Telelynx, Inc.
00:04:73	Photonex               # Photonex Corporation
00:04:74	Legrand
00:04:75	3Com                   # 3 Com Corporation
00:04:76	3Com                   # 3 Com Corporation
00:04:77	Scalant                # Scalant Systems, Inc.
00:04:78	GStarTechn             # G. Star Technology Corporation
00:04:79	Radius                 # Radius Co., Ltd.
00:04:7A	AxxessitAs             # AXXESSIT ASA
00:04:7B	Schlumberg             # Schlumberger
00:04:7C	Skidata                # Skidata AG
00:04:7D	Pelco
00:04:7E	Optelecom=             # Optelecom=NKF
00:04:7F	ChrMayr                # Chr. Mayr GmbH & Co. KG
00:04:80	FoundryNet             # Foundry Networks, Inc.
00:04:81	EconoliteC             # Econolite Control Products, Inc.
00:04:82	Medialogic             # Medialogic Corp.
00:04:83	DeltronTec             # Deltron Technology, Inc.
00:04:84	Amann                  # Amann GmbH
00:04:85	Picolight
00:04:86	IttcUniver             # ITTC, University of Kansas
00:04:87	CogencySem             # Cogency Semiconductor, Inc.
00:04:88	EurothermC             # Eurotherm Controls
00:04:89	YafoNetwor             # YAFO Networks, Inc.
00:04:8A	TemiaVertr             # Temia Vertriebs GmbH
00:04:8B	Poscon                 # Poscon Corporation
00:04:8C	NaynaNetwo             # Nayna Networks, Inc.
00:04:8D	ToneComman             # Tone Commander Systems, Inc.
00:04:8E	OhmTechLab             # Ohm Tech Labs, Inc.
00:04:8F	Td                     # TD Systems Corp.
00:04:90	OpticalAcc             # Optical Access
00:04:91	Technovisi             # Technovision, Inc.
00:04:92	HiveIntern             # Hive Internet, Ltd.
00:04:93	TsinghuaUn             # Tsinghua Unisplendour Co., Ltd.
00:04:94	Breezecom              # Breezecom, Ltd.
00:04:95	TejasNetwo             # Tejas Networks
00:04:96	ExtremeNet             # Extreme Networks
00:04:97	Macrosyste             # MacroSystem Digital Video AG
00:04:98	MahiNetwor             # Mahi Networks
00:04:99	Chino                  # Chino Corporation
00:04:9A	Cisco                  # Cisco Systems, Inc.
00:04:9B	Cisco                  # Cisco Systems, Inc.
00:04:9C	SurgientNe             # Surgient Networks, Inc.
00:04:9D	IpanemaTec             # Ipanema Technologies
00:04:9E	Wirelink               # Wirelink Co., Ltd.
00:04:9F	FreescaleS             # Freescale Semiconductor
00:04:A0	VerityInst             # Verity Instruments, Inc.
00:04:A1	PathwayCon             # Pathway Connectivity
00:04:A2	LSIJapan               # L.S.I. Japan Co., Ltd.
00:04:A3	MicrochipT             # Microchip Technology, Inc.
00:04:A4	Netenabled             # NetEnabled, Inc.
00:04:A5	BarcoProje             # Barco Projection Systems NV
00:04:A6	SafTehnika             # SAF Tehnika Ltd.
00:04:A7	Fabiatech              # FabiaTech Corporation
00:04:A8	BroadmaxTe             # Broadmax Technologies, Inc.
00:04:A9	Sandstream             # SandStream Technologies, Inc.
00:04:AA	JetstreamC             # Jetstream Communications
00:04:AB	ComverseNe             # Comverse Network Systems, Inc.
00:04:AC	Ibm                    # IBM CORP.
00:04:AD	MalibuNetw             # Malibu Networks
00:04:AE	LiquidMetr             # Liquid Metronics
00:04:AF	DigitalFou             # Digital Fountain, Inc.
00:04:B0	Elesign                # ELESIGN Co., Ltd.
00:04:B1	SignalTech             # Signal Technology, Inc.
00:04:B2	EssegiSrl              # ESSEGI SRL
00:04:B3	Videotek               # Videotek, Inc.
00:04:B4	Ciac
00:04:B5	Equitrac               # Equitrac Corporation
00:04:B6	StratexNet             # Stratex Networks, Inc.
00:04:B7	AmbITHoldi             # AMB i.t. Holding
00:04:B8	Kumahira               # Kumahira Co., Ltd.
00:04:B9	SISoubou               # S.I. Soubou, Inc.
00:04:BA	KddMediaWi             # KDD Media Will Corporation
00:04:BB	Bardac                 # Bardac Corporation
00:04:BC	Giantec                # Giantec, Inc.
00:04:BD	MotorolaBc             # Motorola BCS
00:04:BE	Optxcon                # OptXCon, Inc.
00:04:BF	Versalogic             # VersaLogic Corp.
00:04:C0	Cisco                  # Cisco Systems, Inc.
00:04:C1	Cisco                  # Cisco Systems, Inc.
00:04:C2	Magnipix               # Magnipix, Inc.
00:04:C3	CastorInfo             # CASTOR Informatique
00:04:C4	AllenHeath             # Allen & Heath Limited
00:04:C5	AseTechnol             # ASE Technologies, USA
00:04:C6	YamahaMoto             # Yamaha Motor Co., Ltd.
00:04:C7	Netmount
00:04:C8	LibaMaschi             # LIBA Maschinenfabrik GmbH
00:04:C9	MicroElect             # Micro Electron Co., Ltd.
00:04:CA	Freems                 # FreeMs Corp.
00:04:CB	TdsoftComm             # Tdsoft Communication, Ltd.
00:04:CC	PeekTraffi             # Peek Traffic B.V.
00:04:CD	Informedia             # Informedia Research Group
00:04:CE	PatriaAilo             # Patria Ailon
00:04:CF	SeagateTec             # Seagate Technology
00:04:D0	SoftlinkSR             # Softlink s.r.o.
00:04:D1	DrewTechno             # Drew Technologies, Inc.
00:04:D2	AdconTelem             # Adcon Telemetry GmbH
00:04:D3	Toyokeiki              # Toyokeiki Co., Ltd.
00:04:D4	ProviewEle             # Proview Electronics Co., Ltd.
00:04:D5	HitachiCom             # Hitachi Communication Systems, Inc.
00:04:D6	TakagiIndu             # Takagi Industrial Co., Ltd.
00:04:D7	OmitecInst             # Omitec Instrumentation Ltd.
00:04:D8	Ipwireless             # IPWireless, Inc.
00:04:D9	TitanElect             # Titan Electronics, Inc.
00:04:DA	RelaxTechn             # Relax Technology, Inc.
00:04:DB	TellusGrou             # Tellus Group Corp.
00:04:DC	NortelNetw             # Nortel Networks
00:04:DD	Cisco                  # Cisco Systems, Inc.
00:04:DE	Cisco                  # Cisco Systems, Inc.
00:04:DF	TeracomTel             # Teracom Telematica Ltda.
00:04:E0	ProcketNet             # Procket Networks
00:04:E1	InfiniorMi             # Infinior Microsystems
00:04:E2	SmcNetwork             # SMC Networks, Inc.
00:04:E3	AcctonTech             # Accton Technology Corp.
00:04:E4	DaeryungIn             # Daeryung Ind., Inc.
00:04:E5	Glonet                 # Glonet Systems, Inc.
00:04:E6	BanyanNetw             # Banyan Network Private Limited
00:04:E7	Lightpoint             # Lightpointe Communications, Inc
00:04:E8	Ier                    # IER, Inc.
00:04:E9	Infiniswit             # Infiniswitch Corporation
00:04:EA	Hewlett-Pa             # Hewlett-Packard Company
00:04:EB	PaxonetCom             # Paxonet Communications, Inc.
00:04:EC	MemoboxSa              # Memobox SA
00:04:ED	BillionEle             # Billion Electric Co., Ltd.
00:04:EE	LincolnEle             # Lincoln Electric Company
00:04:EF	Polestar               # Polestar Corp.
00:04:F0	Internatio             # International Computers, Ltd
00:04:F1	Wherenet
00:04:F2	Polycom
00:04:F3	FsForth-Sy             # FS FORTH-SYSTEME GmbH
00:04:F4	InfiniteEl             # Infinite Electronics Inc.
00:04:F5	SnowshoreN             # SnowShore Networks, Inc.
00:04:F6	Amphus
00:04:F7	OmegaBand              # Omega Band, Inc.
00:04:F8	Qualicable             # QUALICABLE TV Industria E Com., Ltda
00:04:F9	XteraCommu             # Xtera Communications, Inc.
00:04:FA	NbsTechnol             # NBS Technologies Inc.
00:04:FB	Commtech               # Commtech, Inc.
00:04:FC	StratusCom             # Stratus Computer (DE), Inc.
00:04:FD	JapanContr             # Japan Control Engineering Co., Ltd.
00:04:FE	PelagoNetw             # Pelago Networks
00:04:FF	Acronet                # Acronet Co., Ltd.
00:05:00	Cisco                  # Cisco Systems, Inc.
00:05:01	Cisco                  # Cisco Systems, Inc.
00:05:02	AppleCompu             # APPLE COMPUTER
00:05:03	Iconag
00:05:04	NarayInfor             # Naray Information & Communication Enterprise
00:05:05	Integratio             # Systems Integration Solutions, Inc.
00:05:06	ReddoNetwo             # Reddo Networks AB
00:05:07	FineApplia             # Fine Appliance Corp.
00:05:08	Inetcam                # Inetcam, Inc.
00:05:09	AvocNishim             # AVOC Nishimura Ltd.
00:05:0A	IcsSpa                 # ICS Spa
00:05:0B	Sicom                  # SICOM Systems, Inc.
00:05:0C	NetworkPho             # Network Photonics, Inc.
00:05:0D	MidstreamT             # Midstream Technologies, Inc.
00:05:0E	3ware                  # 3ware, Inc.
00:05:0F	TanakaS/S              # Tanaka S/S Ltd.
00:05:10	InfiniteSh             # Infinite Shanghai Communication Terminals Ltd.
00:05:11	Complement             # Complementary Technologies Ltd
00:05:12	Meshnetwor             # MeshNetworks, Inc.
00:05:13	VtlinxMult             # VTLinx Multimedia Systems, Inc.
00:05:14	Kdt                    # KDT Systems Co., Ltd.
00:05:15	Nuark                  # Nuark Co., Ltd.
00:05:16	SmartModul             # SMART Modular Technologies
00:05:17	Shellcomm              # Shellcomm, Inc.
00:05:18	JupitersTe             # Jupiters Technology
00:05:19	SiemensBui             # Siemens Building Technologies AG,
00:05:1A	3comEurope             # 3Com Europe Ltd.
00:05:1B	MagicContr             # Magic Control Technology Corporation
00:05:1C	XnetTechno             # Xnet Technology Corp.
00:05:1D	Airocon                # Airocon, Inc.
00:05:1E	BrocadeCom             # Brocade Communications Systems, Inc.
00:05:1F	TaijinMedi             # Taijin Media Co., Ltd.
00:05:20	Smartronix             # Smartronix, Inc.
00:05:21	ControlMic             # Control Microsystems
00:05:22	Lea*D                  # LEA*D Corporation, Inc.
00:05:23	AvlList                # AVL List GmbH
00:05:24	BtlSystemH             # BTL System (HK) Limited
00:05:25	PuretekInd             # Puretek Industrial Co., Ltd.
00:05:26	Ipas                   # IPAS GmbH
00:05:27	SjTek                  # SJ Tek Co. Ltd
00:05:28	NewFocus               # New Focus, Inc.
00:05:29	ShanghaiBr             # Shanghai Broadan Communication Technology Co., Ltd
00:05:2A	IkegamiTsu             # Ikegami Tsushinki Co., Ltd.
00:05:2B	Horiba                 # HORIBA, Ltd.
00:05:2C	SupremeMag             # Supreme Magic Corporation
00:05:2D	ZoltrixInt             # Zoltrix International Limited
00:05:2E	CintaNetwo             # Cinta Networks
00:05:2F	LevitonVoi             # Leviton Voice and Data
00:05:30	Andiamo                # Andiamo Systems, Inc.
00:05:31	Cisco                  # Cisco Systems, Inc.
00:05:32	Cisco                  # Cisco Systems, Inc.
00:05:33	Sanera                 # Sanera Systems, Inc.
00:05:34	NorthstarE             # Northstar Engineering Ltd.
00:05:35	ChipPc                 # Chip PC Ltd.
00:05:36	DanamCommu             # Danam Communications, Inc.
00:05:37	NetsTechno             # Nets Technology Co., Ltd.
00:05:38	Merilus                # Merilus, Inc.
00:05:39	ABrandNewW             # A Brand New World in Sweden AB
00:05:3A	Willowglen             # Willowglen Services Pte Ltd
00:05:3B	HarbourNet             # Harbour Networks Ltd., Co. Beijing
00:05:3C	Xircom
00:05:3D	Agere                  # Agere Systems
00:05:3E	KidSysteme             # KID Systeme GmbH
00:05:3F	Visiontek              # VisionTek, Inc.
00:05:40	Fast                   # FAST Corporation
00:05:41	Advanced               # Advanced Systems Co., Ltd.
00:05:42	Otari                  # Otari, Inc.
00:05:43	IqWireless             # IQ Wireless GmbH
00:05:44	ValleyTech             # Valley Technologies, Inc.
00:05:45	InternetPh             # Internet Photonics
00:05:46	KddiNetwor             # KDDI Network & Solultions Inc.
00:05:47	StarentNet             # Starent Networks
00:05:48	Disco                  # Disco Corporation
00:05:49	SaliraOpti             # Salira Optical Network Systems
00:05:4A	ArioDataNe             # Ario Data Networks, Inc.
00:05:4B	MicroInnov             # Micro Innovation AG
00:05:4C	RfInnovati             # RF Innovations Pty Ltd
00:05:4D	BransTechn             # Brans Technologies, Inc.
00:05:4E	PhilipsCom             # Philips Components
00:05:4F	Private
00:05:50	Vcomms                 # Vcomms Limited
00:05:51	FSElektron             # F & S Elektronik Systeme GmbH
00:05:52	XycotecCom             # Xycotec Computer GmbH
00:05:53	Dvc                    # DVC Company, Inc.
00:05:54	RangestarW             # Rangestar Wireless
00:05:55	JapanCashM             # Japan Cash Machine Co., Ltd.
00:05:56	360                    # 360 Systems
00:05:57	AgileTv                # Agile TV Corporation
00:05:58	Synchronou             # Synchronous, Inc.
00:05:59	IntracomSA             # Intracom S.A.
00:05:5A	PowerDsine             # Power Dsine Ltd.
00:05:5B	CharlesInd             # Charles Industries, Ltd.
00:05:5C	Kowa                   # Kowa Company, Ltd.
00:05:5D	D-Link                 # D-Link Systems, Inc.
00:05:5E	Cisco                  # Cisco Systems, Inc.
00:05:5F	Cisco                  # Cisco Systems, Inc.
00:05:60	LeaderComm             # LEADER COMM.CO., LTD
00:05:61	NacImageTe             # nac Image Technology, Inc.
00:05:62	DigitalVie             # Digital View Limited
00:05:63	J-Works                # J-Works, Inc.
00:05:64	TsinghuaBi             # Tsinghua Bitway Co., Ltd.
00:05:65	TailynComm             # Tailyn Communication Company Ltd.
00:05:66	SecuiCom               # Secui.com Corporation
00:05:67	EtymonicDe             # Etymonic Design, Inc.
00:05:68	PiltofishN             # Piltofish Networks AB
00:05:69	Vmware                 # VMWARE, Inc.
00:05:6A	HeuftSyste             # Heuft Systemtechnik GmbH
00:05:6B	CPTechnolo             # C.P. Technology Co., Ltd.
00:05:6C	HungChang              # Hung Chang Co., Ltd.
00:05:6D	Pacific                # Pacific Corporation
00:05:6E	NationalEn             # National Enhance Technology, Inc.
00:05:6F	InnomediaT             # Innomedia Technologies Pvt. Ltd.
00:05:70	Baydel                 # Baydel Ltd.
00:05:71	SeiwaElect             # Seiwa Electronics Co.
00:05:72	Deonet                 # Deonet Co., Ltd.
00:05:73	Cisco                  # Cisco Systems, Inc.
00:05:74	Cisco                  # Cisco Systems, Inc.
00:05:75	Cds-Electr             # CDS-Electronics BV
00:05:76	NsmTechnol             # NSM Technology Ltd.
00:05:77	SmInformat             # SM Information & Communication
00:05:78	Private
00:05:79	UniversalC             # Universal Control Solution Corp.
00:05:7A	HatterasNe             # Hatteras Networks
00:05:7B	ChungNamEl             # Chung Nam Electronic Co., Ltd.
00:05:7C	RcoSecurit             # RCO Security AB
00:05:7D	SunCommuni             # Sun Communications, Inc.
00:05:7E	EckelmannS             # Eckelmann Steuerungstechnik GmbH
00:05:7F	AcqisTechn             # Acqis Technology
00:05:80	Fibrolan               # Fibrolan Ltd.
00:05:81	SnellWilco             # Snell & Wilcox Ltd.
00:05:82	ClearcubeT             # ClearCube Technology
00:05:83	Imagecom               # ImageCom Limited
00:05:84	Absoluteva             # AbsoluteValue Systems, Inc.
00:05:85	JuniperNet             # Juniper Networks, Inc.
00:05:86	LucentTech             # Lucent Technologies
00:05:87	Locus                  # Locus, Incorporated
00:05:88	Sensoria               # Sensoria Corp.
00:05:89	NationalDa             # National Datacomputer
00:05:8A	Netcom                 # Netcom Co., Ltd.
00:05:8B	Ipmental               # IPmental, Inc.
00:05:8C	Opentech               # Opentech Inc.
00:05:8D	LynxPhoton             # Lynx Photonic Networks, Inc.
00:05:8E	Flextronic             # Flextronics International GmbH & Co. Nfg. KG
00:05:8F	Clcsoft                # CLCsoft co.
00:05:90	Swissvoice             # Swissvoice Ltd.
00:05:91	ActiveSili             # Active Silicon Ltd.
00:05:92	Pultek                 # Pultek Corp.
00:05:93	GrammarEng             # Grammar Engine Inc.
00:05:94	IxxatAutom             # IXXAT Automation GmbH
00:05:95	Alesis                 # Alesis Corporation
00:05:96	Genotech               # Genotech Co., Ltd.
00:05:97	EagleTraff             # Eagle Traffic Control Systems
00:05:98	CronosSRL              # CRONOS S.r.l.
00:05:99	DrsTestAnd             # DRS Test and Energy Management or DRS-TEM
00:05:9A	Cisco                  # Cisco Systems, Inc.
00:05:9B	Cisco                  # Cisco Systems, Inc.
00:05:9C	Kleinknech             # Kleinknecht GmbH, Ing. Buero
00:05:9D	DanielComp             # Daniel Computing Systems, Inc.
00:05:9E	Zinwell                # Zinwell Corporation
00:05:9F	YottaNetwo             # Yotta Networks, Inc.
00:05:A0	MobilineKf             # MOBILINE Kft.
00:05:A1	Zenocom
00:05:A2	CeloxNetwo             # CELOX Networks
00:05:A3	Qei                    # QEI, Inc.
00:05:A4	LucidVoice             # Lucid Voice Ltd.
00:05:A5	Kott
00:05:A6	ExtronElec             # Extron Electronics
00:05:A7	Hyperchip              # Hyperchip, Inc.
00:05:A8	WyleElectr             # WYLE ELECTRONICS
00:05:A9	PrincetonN             # Princeton Networks, Inc.
00:05:AA	MooreIndus             # Moore Industries International Inc.
00:05:AB	CyberFone              # Cyber Fone, Inc.
00:05:AC	NorthernDi             # Northern Digital, Inc.
00:05:AD	TopspinCom             # Topspin Communications, Inc.
00:05:AE	MediaportU             # Mediaport USA
00:05:AF	InnoscanCo             # InnoScan Computing A/S
00:05:B0	KoreaCompu             # Korea Computer Technology Co., Ltd.
00:05:B1	AsbTechnol             # ASB Technology BV
00:05:B2	Medison                # Medison Co., Ltd.
00:05:B3	Asahi-Engi             # Asahi-Engineering Co., Ltd.
00:05:B4	Aceex                  # Aceex Corporation
00:05:B5	BroadcomTe             # Broadcom Technologies
00:05:B6	InsysMicro             # INSYS Microelectronics GmbH
00:05:B7	ArborTechn             # Arbor Technology Corp.
00:05:B8	Electronic             # Electronic Design Associates, Inc.
00:05:B9	Airvana                # Airvana, Inc.
00:05:BA	AreaNetwoe             # Area Netwoeks, Inc.
00:05:BB	Myspace                # Myspace AB
00:05:BC	Resorsys               # Resorsys Ltd.
00:05:BD	RoaxBv                 # ROAX BV
00:05:BE	KongsbergS             # Kongsberg Seatex AS
00:05:BF	JustezyTec             # JustEzy Technology, Inc.
00:05:C0	DigitalNet             # Digital Network Alacarte Co., Ltd.
00:05:C1	A-KyungMot             # A-Kyung Motion, Inc.
00:05:C2	Soronti                # Soronti, Inc.
00:05:C3	PacificIns             # Pacific Instruments, Inc.
00:05:C4	Telect                 # Telect, Inc.
00:05:C5	FlagaHf                # Flaga HF
00:05:C6	TrizCommun             # Triz Communications
00:05:C7	I/F-Com                # I/F-COM A/S
00:05:C8	Verytech
00:05:C9	LgInnotek              # LG Innotek
00:05:CA	HitronTech             # Hitron Technology, Inc.
00:05:CB	RoisTechno             # ROIS Technologies, Inc.
00:05:CC	SumtelComm             # Sumtel Communications, Inc.
00:05:CD	Denon                  # Denon, Ltd.
00:05:CE	ProlinkMic             # Prolink Microsystems Corporation
00:05:CF	ThunderRiv             # Thunder River Technologies, Inc.
00:05:D0	Solinet                # Solinet Systems
00:05:D1	Metavector             # Metavector Technologies
00:05:D2	DapTechnol             # DAP Technologies
00:05:D3	Eproductio             # eProduction Solutions, Inc.
00:05:D4	Futuresmar             # FutureSmart Networks, Inc.
00:05:D5	SpeedcomWi             # Speedcom Wireless
00:05:D6	TitanWirel             # Titan Wireless
00:05:D7	VistaImagi             # Vista Imaging, Inc.
00:05:D8	Arescom                # Arescom, Inc.
00:05:D9	TechnoVall             # Techno Valley, Inc.
00:05:DA	ApexAutoma             # Apex Automationstechnik
00:05:DB	Nentec                 # Nentec GmbH
00:05:DC	Cisco                  # Cisco Systems, Inc.
00:05:DD	Cisco                  # Cisco Systems, Inc.
00:05:DE	GiFoneKore             # Gi Fone Korea, Inc.
00:05:DF	Electronic             # Electronic Innovation, Inc.
00:05:E0	Empirix                # Empirix Corp.
00:05:E1	TrellisPho             # Trellis Photonics, Ltd.
00:05:E2	CreativNet             # Creativ Network Technologies
00:05:E3	LightsandC             # LightSand Communications, Inc.
00:05:E4	RedLionCon             # Red Lion Controls L.P.
00:05:E5	Renishaw               # Renishaw PLC
00:05:E6	Egenera                # Egenera, Inc.
00:05:E7	Netrake                # Netrake Corp.
00:05:E8	Turbowave              # TurboWave, Inc.
00:05:E9	UnicessNet             # Unicess Network, Inc.
00:05:EA	Rednix
00:05:EB	BlueRidgeN             # Blue Ridge Networks, Inc.
00:05:EC	Mosaic                 # Mosaic Systems Inc.
00:05:ED	TechnikumJ             # Technikum Joanneum GmbH
00:05:EE	BewatorGro             # BEWATOR Group
00:05:EF	AdoirDigit             # ADOIR Digital Technology
00:05:F0	Satec
00:05:F1	Vrcom                  # Vrcom, Inc.
00:05:F2	PowerR                 # Power R, Inc.
00:05:F3	Weboyn
00:05:F4	SystemBase             # System Base Co., Ltd.
00:05:F5	OyoGeospac             # OYO Geospace Corp.
00:05:F6	YoungChang             # Young Chang Co. Ltd.
00:05:F7	AnalogDevi             # Analog Devices, Inc.
00:05:F8	RealTimeAc             # Real Time Access, Inc.
00:05:F9	Toa                    # TOA Corporation
00:05:FA	Ipoptical              # IPOptical, Inc.
00:05:FB	Sharegate              # ShareGate, Inc.
00:05:FC	SchenckPeg             # Schenck Pegasus Corp.
00:05:FD	Packetligh             # PacketLight Networks Ltd.
00:05:FE	TraficonNV             # Traficon N.V.
00:05:FF	SnsSolutio             # SNS Solutions, Inc.
00:06:00	ToshibaTel             # Toshiba Teli Corporation
00:06:01	Otanikeiki             # Otanikeiki Co., Ltd.
00:06:02	CirkitechE             # Cirkitech Electronics Co.
00:06:03	BakerHughe             # Baker Hughes Inc.
00:06:04	@TrackComm             # @Track Communications, Inc.
00:06:05	InncomInte             # Inncom International, Inc.
00:06:06	Rapidwan               # RapidWAN, Inc.
00:06:07	OmniDirect             # Omni Directional Control Technology Inc.
00:06:08	At-SkySas              # At-Sky SAS
00:06:09	Crossport              # Crossport Systems
00:06:0A	Blue2space
00:06:0B	Paceline               # Paceline Systems Corporation
00:06:0C	MelcoIndus             # Melco Industries, Inc.
00:06:0D	HP
00:06:0E	Igys                   # IGYS Systems, Inc.
00:06:0F	NaradNetwo             # Narad Networks Inc
00:06:10	AbeonaNetw             # Abeona Networks Inc
00:06:11	ZeusWirele             # Zeus Wireless, Inc.
00:06:12	Accusys                # Accusys, Inc.
00:06:13	KawasakiMi             # Kawasaki Microelectronics Incorporated
00:06:14	PrismHoldi             # Prism Holdings
00:06:15	KimotoElec             # Kimoto Electric Co., Ltd.
00:06:16	TelNet                 # Tel Net Co., Ltd.
00:06:17	Redswitch              # Redswitch Inc.
00:06:18	DigipowerM             # DigiPower Manufacturing Inc.
00:06:19	Connection             # Connection Technology Systems
00:06:1A	Zetari                 # Zetari Inc.
00:06:1B	PortableIb             # Portable Systems, IBM Japan Co, Ltd
00:06:1C	HoshinoMet             # Hoshino Metal Industries, Ltd.
00:06:1D	MipTelecom             # MIP Telecom, Inc.
00:06:1E	Maxan                  # Maxan Systems
00:06:1F	VisionComp             # Vision Components GmbH
00:06:20	SerialSyst             # Serial System Ltd.
00:06:21	Hinox                  # Hinox, Co., Ltd.
00:06:22	ChungFuChe             # Chung Fu Chen Yeh Enterprise Corp.
00:06:23	MgeUpsFran             # MGE UPS Systems France
00:06:24	GentnerCom             # Gentner Communications Corp.
00:06:25	LinksysGro             # The Linksys Group, Inc.
00:06:26	Mwe                    # MWE GmbH
00:06:27	UniwideTec             # Uniwide Technologies, Inc.
00:06:28	Cisco                  # Cisco Systems, Inc.
00:06:29	Ibm                    # IBM CORPORATION
00:06:2A	Cisco                  # Cisco Systems, Inc.
00:06:2B	Intraserve             # INTRASERVER TECHNOLOGY
00:06:2C	NetworkRob             # Network Robots, Inc.
00:06:2D	TouchstarT             # TouchStar Technologies, L.L.C.
00:06:2E	AristosLog             # Aristos Logic Corp.
00:06:2F	Pivotech               # Pivotech Systems Inc.
00:06:30	AdtranzSwe             # Adtranz Sweden
00:06:31	OpticalSol             # Optical Solutions, Inc.
00:06:32	MescoEngin             # Mesco Engineering GmbH
00:06:33	SmithsHeim             # Smiths Heimann Biometric Systems
00:06:34	GteAirfone             # GTE Airfone Inc.
00:06:35	PacketairN             # PacketAir Networks, Inc.
00:06:36	JedaiBroad             # Jedai Broadband Networks
00:06:37	Toptrend-M             # Toptrend-Meta Information (ShenZhen) Inc.
00:06:38	SungjinC&C             # Sungjin C&C Co., Ltd.
00:06:39	Newtec
00:06:3A	DuraMicro              # Dura Micro, Inc.
00:06:3B	ArcturusNe             # Arcturus Networks, Inc.
00:06:3C	NmiElectro             # NMI Electronics Ltd
00:06:3D	MicrowaveD             # Microwave Data Systems Inc.
00:06:3E	Opthos                 # Opthos Inc.
00:06:3F	EverexComm             # Everex Communications Inc.
00:06:40	WhiteRockN             # White Rock Networks
00:06:41	Itcn
00:06:42	Genetel                # Genetel Systems Inc.
00:06:43	SonoComput             # SONO Computer Co., Ltd.
00:06:44	Neix                   # NEIX Inc.
00:06:45	MeiseiElec             # Meisei Electric Co. Ltd.
00:06:46	ShenzhenXu             # ShenZhen XunBao Network Technology Co Ltd
00:06:47	EtraliSA               # Etrali S.A.
00:06:48	Seedsware              # Seedsware, Inc.
00:06:49	Quante
00:06:4A	HoneywellK             # Honeywell Co., Ltd. (KOREA)
00:06:4B	Alexon                 # Alexon Co., Ltd.
00:06:4C	InvictaNet             # Invicta Networks, Inc.
00:06:4D	Sencore
00:06:4E	BroadNetTe             # Broad Net Technology Inc.
00:06:4F	Pro-NetsTe             # PRO-NETS Technology Corporation
00:06:50	TiburonNet             # Tiburon Networks, Inc.
00:06:51	AspenNetwo             # Aspen Networks Inc.
00:06:52	Cisco                  # Cisco Systems, Inc.
00:06:53	Cisco                  # Cisco Systems, Inc.
00:06:54	MaxxioTech             # Maxxio Technologies
00:06:55	Yipee                  # Yipee, Inc.
00:06:56	Tactel                 # Tactel AB
00:06:57	MarketCent             # Market Central, Inc.
00:06:58	HelmutFisc             # Helmut Fischer GmbH & Co. KG
00:06:59	EalApeldoo             # EAL (Apeldoorn) B.V.
00:06:5A	Strix                  # Strix Systems
00:06:5B	DellComput             # Dell Computer Corp.
00:06:5C	MalachiteT             # Malachite Technologies, Inc.
00:06:5D	Heidelberg             # Heidelberg Web Systems
00:06:5E	Photuris               # Photuris, Inc.
00:06:5F	EciTelecom             # ECI Telecom - NGTS Ltd.
00:06:60	Nadex                  # NADEX Co., Ltd.
00:06:61	NiaHomeTec             # NIA Home Technologies Corp.
00:06:62	MbmTechnol             # MBM Technology Ltd.
00:06:63	HumanTechn             # Human Technology Co., Ltd.
00:06:64	Fostex                 # Fostex Corporation
00:06:65	SunnyGiken             # Sunny Giken, Inc.
00:06:66	RovingNetw             # Roving Networks
00:06:67	TrippLite              # Tripp Lite
00:06:68	ViconIndus             # Vicon Industries Inc.
00:06:69	DatasoundL             # Datasound Laboratories Ltd
00:06:6A	Infinicon              # InfiniCon Systems, Inc.
00:06:6B	Sysmex                 # Sysmex Corporation
00:06:6C	Robinson               # Robinson Corporation
00:06:6D	Compuprint             # Compuprint S.P.A.
00:06:6E	DeltaElect             # Delta Electronics, Inc.
00:06:6F	KoreaData              # Korea Data Systems
00:06:70	UpponettiO             # Upponetti Oy
00:06:71	Softing                # Softing AG
00:06:72	Netezza
00:06:73	Optelecom-             # Optelecom-nkf
00:06:74	SpectrumCo             # Spectrum Control, Inc.
00:06:75	Banderacom             # Banderacom, Inc.
00:06:76	NovraTechn             # Novra Technologies Inc.
00:06:77	Sick                   # SICK AG
00:06:78	MarantzJap             # Marantz Japan, Inc.
00:06:79	Konami                 # Konami Corporation
00:06:7A	Jmp                    # JMP Systems
00:06:7B	ToplinkC&C             # Toplink C&C Corporation
00:06:7C	Cisco                  # CISCO SYSTEMS, INC.
00:06:7D	Takasago               # Takasago Ltd.
00:06:7E	Wincom                 # WinCom Systems, Inc.
00:06:7F	ReardenSte             # Rearden Steel Technologies
00:06:80	CardAccess             # Card Access, Inc.
00:06:81	GoepelElec             # Goepel Electronic GmbH
00:06:82	Convedia
00:06:83	BravaraCom             # Bravara Communications, Inc.
00:06:84	Biacore                # Biacore AB
00:06:85	Netnearu               # NetNearU Corporation
00:06:86	Zardcom                # ZARDCOM Co., Ltd.
00:06:87	OmnitronTe             # Omnitron Systems Technology, Inc.
00:06:88	TelwaysCom             # Telways Communication Co., Ltd.
00:06:89	YlezTechno             # yLez Technologies Pte Ltd
00:06:8A	NeuronnetR             # NeuronNet Co. Ltd. R&D Center
00:06:8B	AirrunnerT             # AirRunner Technologies, Inc.
00:06:8C	3com                   # 3Com Corporation
00:06:8D	Sepaton                # SEPATON, Inc.
00:06:8E	Hid                    # HID Corporation
00:06:8F	Telemonito             # Telemonitor, Inc.
00:06:90	EuracomCom             # Euracom Communication GmbH
00:06:91	PtInovacao             # PT Inovacao
00:06:92	IntruvertN             # Intruvert Networks, Inc.
00:06:93	FlexusComp             # Flexus Computer Technology, Inc.
00:06:94	Mobillian              # Mobillian Corporation
00:06:95	EnsureTech             # Ensure Technologies, Inc.
00:06:96	AdventNetw             # Advent Networks
00:06:97	RDCenter               # R & D Center
00:06:98	EgniteSoft             # egnite Software GmbH
00:06:99	VidaDesign             # Vida Design Co.
00:06:9A	ETel                   # e & Tel
00:06:9B	AvtAudioVi             # AVT Audio Video Technologies GmbH
00:06:9C	Transmode              # Transmode Systems AB
00:06:9D	PetardsMob             # Petards Mobile Intelligence
00:06:9E	Uniqa                  # UNIQA, Inc.
00:06:9F	KuokoaNetw             # Kuokoa Networks
00:06:A0	MxImaging              # Mx Imaging
00:06:A1	CelsianTec             # Celsian Technologies, Inc.
00:06:A2	Microtune              # Microtune, Inc.
00:06:A3	Bitran                 # Bitran Corporation
00:06:A4	Innowell               # INNOWELL Corp.
00:06:A5	Pinon                  # PINON Corp.
00:06:A6	ArtisticLi             # Artistic Licence (UK) Ltd
00:06:A7	Primarion
00:06:A8	KcTechnolo             # KC Technology, Inc.
00:06:A9	UniversalI             # Universal Instruments Corp.
00:06:AA	Miltope                # Miltope Corporation
00:06:AB	W-Link                 # W-Link Systems, Inc.
00:06:AC	Intersoft              # Intersoft Co.
00:06:AD	KbElectron             # KB Electronics Ltd.
00:06:AE	HimachalFu             # Himachal Futuristic Communications Ltd
00:06:AF	Private
00:06:B0	ComtechEfD             # Comtech EF Data Corp.
00:06:B1	Sonicwall
00:06:B2	Linxtek                # Linxtek Co.
00:06:B3	Diagraph               # Diagraph Corporation
00:06:B4	VorneIndus             # Vorne Industries, Inc.
00:06:B5	Luminent               # Luminent, Inc.
00:06:B6	Nir-OrIsra             # Nir-Or Israel Ltd.
00:06:B7	Telem                  # TELEM GmbH
00:06:B8	BandspeedP             # Bandspeed Pty Ltd
00:06:B9	A5tek                  # A5TEK Corp.
00:06:BA	WestwaveCo             # Westwave Communications
00:06:BB	AtiTechnol             # ATI Technologies Inc.
00:06:BC	Macrolink              # Macrolink, Inc.
00:06:BD	Bntechnolo             # BNTECHNOLOGY Co., Ltd.
00:06:BE	BaumerOptr             # Baumer Optronic GmbH
00:06:BF	AccellaTec             # Accella Technologies Co., Ltd.
00:06:C0	UnitedInte             # United Internetworks, Inc.
00:06:C1	Cisco                  # CISCO SYSTEMS, INC.
00:06:C2	Smartmatic             # Smartmatic Corporation
00:06:C3	SchindlerE             # Schindler Elevators Ltd.
00:06:C4	Piolink                # Piolink Inc.
00:06:C5	InnoviTech             # INNOVI Technologies Limited
00:06:C6	Lesswire               # lesswire AG
00:06:C7	RfnetTechn             # RFNET Technologies Pte Ltd (S)
00:06:C8	SumitomoMe             # Sumitomo Metal Micro Devices, Inc.
00:06:C9	TechnicalM             # Technical Marketing Research, Inc.
00:06:CA	AmericanCo             # American Computer & Digital Components, Inc. (ACDC)
00:06:CB	JotronElec             # Jotron Electronics A/S
00:06:CC	JmiElectro             # JMI Electronics Co., Ltd.
00:06:CD	CreoIl                 # Creo IL. Ltd.
00:06:CE	Dateno
00:06:CF	ThalesAvio             # Thales Avionics In-Flight Systems, LLC
00:06:D0	ElgarElect             # Elgar Electronics Corp.
00:06:D1	TahoeNetwo             # Tahoe Networks, Inc.
00:06:D2	TundraSemi             # Tundra Semiconductor Corp.
00:06:D3	AlphaTelec             # Alpha Telecom, Inc. U.S.A.
00:06:D4	Interactiv             # Interactive Objects, Inc.
00:06:D5	Diamond                # Diamond Systems Corp.
00:06:D6	Cisco                  # Cisco Systems, Inc.
00:06:D7	Cisco                  # Cisco Systems, Inc.
00:06:D8	MapleOptic             # Maple Optical Systems
00:06:D9	Ipm-NetSPA             # IPM-Net S.p.A.
00:06:DA	ItranCommu             # ITRAN Communications Ltd.
00:06:DB	Ichips                 # ICHIPS Co., Ltd.
00:06:DC	SyabasTech             # Syabas Technology (Amquest)
00:06:DD	AtTLaborat             # AT & T Laboratories - Cambridge Ltd
00:06:DE	FlashTechn             # Flash Technology
00:06:DF	Aidonic                # AIDONIC Corporation
00:06:E0	Mat                    # MAT Co., Ltd.
00:06:E1	TechnoTrad             # Techno Trade s.a
00:06:E2	CeemaxTech             # Ceemax Technology Co., Ltd.
00:06:E3	Quantitati             # Quantitative Imaging Corporation
00:06:E4	CitelTechn             # Citel Technologies Ltd.
00:06:E5	FujianNewl             # Fujian Newland Computer Ltd. Co.
00:06:E6	DongyangTe             # DongYang Telecom Co., Ltd.
00:06:E7	BitBlitzCo             # Bit Blitz Communications Inc.
00:06:E8	OpticalNet             # Optical Network Testing, Inc.
00:06:E9	Intime                 # Intime Corp.
00:06:EA	Elzet80Mik             # ELZET80 Mikrocomputer GmbH&Co. KG
00:06:EB	GlobalData             # Global Data
00:06:EC	M/AComPriv             # M/A COM Private Radio System Inc.
00:06:ED	InaraNetwo             # Inara Networks
00:06:EE	ShenyangNe             # Shenyang Neu-era Information & Technology Stock Co., Ltd
00:06:EF	Maxxan                 # Maxxan Systems, Inc.
00:06:F0	Digeo                  # Digeo, Inc.
00:06:F1	Optillion
00:06:F2	PlatysComm             # Platys Communications
00:06:F3	AccelightN             # AcceLight Networks
00:06:F4	PrimeElect             # Prime Electronics & Satellitics Inc.
00:06:F8	CpuTechnol             # CPU Technology, Inc.
00:06:F9	MitsuiZose             # Mitsui Zosen Systems Research Inc.
00:06:FA	IpSquare               # IP SQUARE Co, Ltd.
00:06:FB	HitachiPri             # Hitachi Printing Solutions, Ltd.
00:06:FC	Fnet                   # Fnet Co., Ltd.
00:06:FD	ComjetInfo             # Comjet Information Systems Corp.
00:06:FE	CelionNetw             # Celion Networks, Inc.
00:06:FF	Sheba                  # Sheba Systems Co., Ltd.
00:07:00	Zettamedia             # Zettamedia Korea
00:07:01	Cisco		# RACAL-DATACOM
00:07:02	VarianMedi             # Varian Medical Systems
00:07:03	CseeTransp             # CSEE Transport
00:07:05	EndressHau             # Endress & Hauser GmbH & Co
00:07:06	Sanritz                # Sanritz Corporation
00:07:07	Interalia              # Interalia Inc.
00:07:08	Bitrage                # Bitrage Inc.
00:07:09	Westerstra             # Westerstrand Urfabrik AB
00:07:0A	UnicomAuto             # Unicom Automation Co., Ltd.
00:07:0B	OctalSa                # Octal, SA
00:07:0C	Sva-Intrus             # SVA-Intrusion.com Co. Ltd.
00:07:0D	Cisco                  # Cisco Systems Inc.
00:07:0E	Cisco                  # Cisco Systems Inc.
00:07:0F	Fujant                 # Fujant, Inc.
00:07:10	Adax                   # Adax, Inc.
00:07:11	Acterna
00:07:12	JalInforma             # JAL Information Technology
00:07:13	IpOne                  # IP One, Inc.
00:07:14	Brightcom
00:07:15	GeneralRes             # General Research of Electronics, Inc.
00:07:16	JSMarine               # J & S Marine Ltd.
00:07:17	WielandEle             # Wieland Electric GmbH
00:07:18	Icantek                # iCanTek Co., Ltd.
00:07:19	Mobiis                 # Mobiis Co., Ltd.
00:07:1A	Finedigita             # Finedigital Inc.
00:07:1B	PositionTe             # Position Technology Inc.
00:07:1C	At&TFixedW             # AT&T Fixed Wireless Services
00:07:1D	SatelsaSis             # Satelsa Sistemas Y Aplicaciones De Telecomunicaciones, S.A.
00:07:1E	Tri-MEngin             # Tri-M Engineering / Nupak Dev. Corp.
00:07:1F	EuropeanIn             # European Systems Integration
00:07:20	Trutzschle             # Trutzschler GmbH & Co. KG
00:07:21	FormacElek             # Formac Elektronik GmbH
00:07:22	NielsenMed             # Nielsen Media Research
00:07:23	ElconSyste             # ELCON Systemtechnik GmbH
00:07:24	Telemax                # Telemax Co., Ltd.
00:07:25	BematechIn             # Bematech International Corp.
00:07:27	ZiHk                   # Zi Corporation (HK) Ltd.
00:07:28	NeoTelecom             # Neo Telecom
00:07:29	KistlerIns             # Kistler Instrumente AG
00:07:2A	InnovanceN             # Innovance Networks
00:07:2B	JungMyungT             # Jung Myung Telecom Co., Ltd.
00:07:2C	Fabricom
00:07:2D	Cnsystems
00:07:2E	NorthNode              # North Node AB
00:07:2F	Intransa               # Intransa, Inc.
00:07:30	HutchisonO             # Hutchison OPTEL Telecom Technology Co., Ltd.
00:07:31	Spiricon               # Spiricon, Inc.
00:07:32	AaeonTechn             # AAEON Technology Inc.
00:07:33	Dancontrol             # DANCONTROL Engineering
00:07:34	Onstor                 # ONStor, Inc.
00:07:35	FlarionTec             # Flarion Technologies, Inc.
00:07:36	DataVideoT             # Data Video Technologies Co., Ltd.
00:07:37	Soriya                 # Soriya Co. Ltd.
00:07:38	YoungTechn             # Young Technology Co., Ltd.
00:07:39	MotionMedi             # Motion Media Technology Ltd.
00:07:3A	InventelSy             # Inventel Systemes
00:07:3B	Tenovis                # Tenovis GmbH & Co KG
00:07:3C	TelecomDes             # Telecom Design
00:07:3D	NanjingPos             # Nanjing Postel Telecommunications Co., Ltd.
00:07:3E	ChinaGreat             # China Great-Wall Computer Shenzhen Co., Ltd.
00:07:3F	WoojyunSys             # Woojyun Systec Co., Ltd.
00:07:40	Melco                  # Melco Inc.
00:07:41	SierraAuto             # Sierra Automated Systems
00:07:42	CurrentTec             # Current Technologies
00:07:43	ChelsioCom             # Chelsio Communications
00:07:44	Unico                  # Unico, Inc.
00:07:45	RadlanComp             # Radlan Computer Communications Ltd.
00:07:46	Turck                  # TURCK, Inc.
00:07:47	Mecalc
00:07:48	ImagingSou             # The Imaging Source Europe
00:07:49	Cenix                  # CENiX Inc.
00:07:4A	CarlValent             # Carl Valentin GmbH
00:07:4B	Daihen                 # Daihen Corporation
00:07:4C	Beicom                 # Beicom Inc.
00:07:4D	ZebraTechn             # Zebra Technologies Corp.
00:07:4E	NaughtyBoy             # Naughty boy co., Ltd.
00:07:4F	Cisco                  # Cisco Systems, Inc.
00:07:50	Cisco                  # Cisco Systems, Inc.
00:07:51	MUT-                   # m.u.t. - GmbH
00:07:52	RhythmWatc             # Rhythm Watch Co., Ltd.
00:07:53	BeijingQxc             # Beijing Qxcomm Technology Co., Ltd.
00:07:54	XyterraCom             # Xyterra Computing, Inc.
00:07:55	LafonSa                # Lafon SA
00:07:56	JuyoungTel             # Juyoung Telecom
00:07:57	TopcallInt             # Topcall International AG
00:07:58	Dragonwave
00:07:59	BorisManuf             # Boris Manufacturing Corp.
00:07:5A	AirProduct             # Air Products and Chemicals, Inc.
00:07:5B	GibsonGuit             # Gibson Guitars
00:07:5C	EastmanKod             # Eastman Kodak Company
00:07:5D	Celleritas             # Celleritas Inc.
00:07:5E	PulsarTech             # Pulsar Technologies, Inc.
00:07:5F	VcsVideoCo             # VCS Video Communication Systems AG
00:07:60	TomisInfor             # TOMIS Information & Telecom Corp.
00:07:61	LogitechSa             # Logitech SA
00:07:62	GroupSense             # Group Sense Limited
00:07:63	SunniwellC             # Sunniwell Cyber Tech. Co., Ltd.
00:07:64	YoungwooTe             # YoungWoo Telecom Co. Ltd.
00:07:65	JadeQuantu             # Jade Quantum Technologies, Inc.
00:07:66	ChouChinIn             # Chou Chin Industrial Co., Ltd.
00:07:67	YuxingElec             # Yuxing Electronics Company Limited
00:07:68	Danfoss                # Danfoss A/S
00:07:69	ItalianaMa             # Italiana Macchi SpA
00:07:6A	Nexteye                # NEXTEYE Co., Ltd.
00:07:6B	Stralfors              # Stralfors AB
00:07:6C	Daehanet               # Daehanet, Inc.
00:07:6D	FlexlightN             # Flexlight Networks
00:07:6E	Sinetica               # Sinetica Corporation Limited
00:07:6F	Synoptics              # Synoptics Limited
00:07:70	Locusnetwo             # Locusnetworks Corporation
00:07:71	EmbeddedSy             # Embedded System Corporation
00:07:72	AlcatelSha             # Alcatel Shanghai Bell Co., Ltd.
00:07:73	AscomPower             # Ascom Powerline Communications Ltd.
00:07:74	GuangzhouT             # GuangZhou Thinker Technology Co. Ltd.
00:07:75	ValenceSem             # Valence Semiconductor, Inc.
00:07:76	FederalApd             # Federal APD
00:07:77	Motah                  # Motah Ltd.
00:07:78	Gerstel                # GERSTEL GmbH & Co. KG
00:07:79	SungilTele             # Sungil Telecom Co., Ltd.
00:07:7A	InfowareSy             # Infoware System Co., Ltd.
00:07:7B	Millimetri             # Millimetrix Broadband Networks
00:07:7C	OntimeNetw             # OnTime Networks
00:07:7E	Elrest                 # Elrest GmbH
00:07:7F	JCommunica             # J Communications Co., Ltd.
00:07:80	BluegigaTe             # Bluegiga Technologies OY
00:07:81	Itron                  # Itron Inc.
00:07:82	NauticusNe             # Nauticus Networks, Inc.
00:07:83	SyncomNetw             # SynCom Network, Inc.
00:07:84	Cisco                  # Cisco Systems Inc.
00:07:85	Cisco                  # Cisco Systems Inc.
00:07:86	WirelessNe             # Wireless Networks Inc.
00:07:87	IdeaSystem             # Idea System Co., Ltd.
00:07:88	Clipcomm               # Clipcomm, Inc.
00:07:89	Eastel                 # Eastel Systems Corporation
00:07:8A	MentorData             # Mentor Data System Inc.
00:07:8B	WegenerCom             # Wegener Communications, Inc.
00:07:8C	Elektronik             # Elektronikspecialisten i Borlange AB
00:07:8D	Netengines             # NetEngines Ltd.
00:07:8E	GarzFriche             # Garz & Friche GmbH
00:07:8F	EmkayInnov             # Emkay Innovative Products
00:07:90	Tri-MTechn             # Tri-M Technologies (s) Limited
00:07:91	Internatio             # International Data Communications, Inc.
00:07:92	SuetronEle             # Suetron Electronic GmbH
00:07:93	ShinSatell             # Shin Satellite Public Company Limited
00:07:94	SimpleDevi             # Simple Devices, Inc.
00:07:95	Elitegroup             # Elitegroup Computer System Co. (ECS)
00:07:96	Lsi                    # LSI Systems, Inc.
00:07:97	Netpower               # Netpower Co., Ltd.
00:07:98	SeleaSrl               # Selea SRL
00:07:99	TippingPoint		# TippingPoint Technologies, Inc.
00:07:9A	Smartsight             # SmartSight Networks Inc.
00:07:9B	AuroraNetw             # Aurora Networks
00:07:9C	GoldenElec             # Golden Electronics Technology Co., Ltd.
00:07:9D	Musashi                # Musashi Co., Ltd.
00:07:9E	Ilinx                  # Ilinx Co., Ltd.
00:07:9F	ActionDigi             # Action Digital Inc.
00:07:A0	E-Watch                # e-Watch Inc.
00:07:A1	ViasysHeal             # VIASYS Healthcare GmbH
00:07:A2	Opteon                 # Opteon Corporation
00:07:A3	OsitisSoft             # Ositis Software, Inc.
00:07:A4	GnNetcom               # GN Netcom Ltd.
00:07:A5	YDK                    # Y.D.K Co. Ltd.
00:07:A6	HomeAutoma             # Home Automation, Inc.
00:07:A7	A-Z                    # A-Z Inc.
00:07:A8	HaierGroup             # Haier Group Technologies Ltd.
00:07:A9	Novasonics
00:07:AA	QuantumDat             # Quantum Data Inc.
00:07:AC	Eolring
00:07:AD	PentaconFo             # Pentacon GmbH Foto-und Feinwerktechnik
00:07:AE	Britestrea             # Britestream Networks, Inc.
00:07:AF	N-Tron                 # N-Tron Corp.
00:07:B0	OfficeDeta             # Office Details, Inc.
00:07:B1	EquatorTec             # Equator Technologies
00:07:B2	Transacces             # Transaccess S.A.
00:07:B3	Cisco                  # Cisco Systems Inc.
00:07:B4	Cisco                  # Cisco Systems Inc.
00:07:B5	AnyOneWire             # Any One Wireless Ltd.
00:07:B6	TelecomTec             # Telecom Technology Ltd.
00:07:B7	SamuraiInd             # Samurai Ind. Prods Eletronicos Ltda
00:07:B8	AmericanPr             # American Predator Corp.
00:07:B9	Ginganet               # Ginganet Corporation
00:07:BA	Utstarcom              # UTStarcom, Inc.
00:07:BB	Candera                # Candera Inc.
00:07:BC	Identix                # Identix Inc.
00:07:BD	Radionet               # Radionet Ltd.
00:07:BE	DatalogicS             # DataLogic SpA
00:07:BF	Armillaire             # Armillaire Technologies, Inc.
00:07:C0	Netzerver              # NetZerver Inc.
00:07:C1	OvertureNe             # Overture Networks, Inc.
00:07:C2	NetsysTele             # Netsys Telecom
00:07:C3	Cirpack
00:07:C4	Jean                   # JEAN Co. Ltd.
00:07:C5	Gcom                   # Gcom, Inc.
00:07:C6	VdsVosskuh             # VDS Vosskuhler GmbH
00:07:C7	Synectics              # Synectics Systems Limited
00:07:C8	Brain21                # Brain21, Inc.
00:07:C9	TechnolSev             # Technol Seven Co., Ltd.
00:07:CA	CreatixPol             # Creatix Polymedia Ges Fur Kommunikaitonssysteme
00:07:CB	FreeboxSa              # Freebox SA
00:07:CC	KabaBenzin             # Kaba Benzing GmbH
00:07:CD	Nmtel                  # NMTEL Co., Ltd.
00:07:CE	Cabletime              # Cabletime Limited
00:07:CF	Anoto                  # Anoto AB
00:07:D0	AutomatEng             # Automat Engenharia de Automaoa Ltda.
00:07:D1	SpectrumSi             # Spectrum Signal Processing Inc.
00:07:D2	LogopakSys             # Logopak Systeme
00:07:D3	StorkDigit             # Stork Digital Imaging B.V.
00:07:D4	ZhejiangYu             # Zhejiang Yutong Network Communication Co Ltd.
00:07:D5	3eTechnolo             # 3e Technologies Int;., Inc.
00:07:D6	Commil                 # Commil Ltd.
00:07:D7	CaporisNet             # Caporis Networks AG
00:07:D8	Hitron                 # Hitron Systems Inc.
00:07:D9	Splicecom
00:07:DA	NeuroTelec             # Neuro Telecom Co., Ltd.
00:07:DB	KiranaNetw             # Kirana Networks, Inc.
00:07:DC	Atek                   # Atek Co, Ltd.
00:07:DD	CradleTech             # Cradle Technologies
00:07:DE	Ecopilt                # eCopilt AB
00:07:DF	Vbrick                 # Vbrick Systems Inc.
00:07:E0	Palm                   # Palm Inc.
00:07:E1	WisCommuni             # WIS Communications Co. Ltd.
00:07:E2	Bitworks               # Bitworks, Inc.
00:07:E3	NavcomTech             # Navcom Technology, Inc.
00:07:E4	Softradio              # SoftRadio Co., Ltd.
00:07:E5	Coup                   # Coup Corporation
00:07:E6	EdgeflowCa             # edgeflow Canada Inc.
00:07:E7	FreewaveTe             # FreeWave Technologies
00:07:E8	StBernardS             # St. Bernard Software
00:07:E9	Intel                  # Intel Corporation
00:07:EA	Massana                # Massana, Inc.
00:07:EB	Cisco                  # Cisco Systems Inc.
00:07:EC	Cisco                  # Cisco Systems Inc.
00:07:ED	Altera                 # Altera Corporation
00:07:EE	TelcoInfor             # telco Informationssysteme GmbH
00:07:EF	LockheedMa             # Lockheed Martin Tactical Systems
00:07:F0	Logisync               # LogiSync Corporation
00:07:F1	TeraburstN             # TeraBurst Networks Inc.
00:07:F2	Ioa                    # IOA Corporation
00:07:F3	Thinkengin             # Thinkengine Networks
00:07:F4	Eletex                 # Eletex Co., Ltd.
00:07:F5	Bridgeco               # Bridgeco Co AG
00:07:F6	QqestSoftw             # Qqest Software Systems
00:07:F7	Galtronics
00:07:F8	Itdevices              # ITDevices, Inc.
00:07:F9	Phonetics              # Phonetics, Inc.
00:07:FA	Itt                    # ITT Co., Ltd.
00:07:FB	GigaStream             # Giga Stream UMTS Technologies GmbH
00:07:FC	Adept                  # Adept Systems Inc.
00:07:FD	Lanergy                # LANergy Ltd.
00:07:FE	Rigaku                 # Rigaku Corporation
00:07:FF	GluonNetwo             # Gluon Networks
00:08:00	Multitech              # MULTITECH SYSTEMS, INC.
00:08:01	HighspeedS             # HighSpeed Surfing Inc.
00:08:02	CompaqComp             # Compaq Computer Corporation
00:08:03	CosTron                # Cos Tron
00:08:04	Ica                    # ICA Inc.
00:08:05	Techno-Hol             # Techno-Holon Corporation
00:08:06	Raonet                 # Raonet Systems, Inc.
00:08:07	AccessDevi             # Access Devices Limited
00:08:08	PptVision              # PPT Vision, Inc.
00:08:09	Systemonic             # Systemonic AG
00:08:0A	Espera-Wer             # Espera-Werke GmbH
00:08:0B	BirkaBpaIn             # Birka BPA Informationssystem AB
00:08:0C	VdaElettro             # VDA elettronica SrL
00:08:0D	Toshiba
00:08:0E	MotorolaBc             # Motorola, BCS
00:08:0F	ProximionF             # Proximion Fiber Optics AB
00:08:10	KeyTechnol             # Key Technology, Inc.
00:08:11	Voix                   # VOIX Corporation
00:08:12	Gm-2                   # GM-2 Corporation
00:08:13	Diskbank               # Diskbank, Inc.
00:08:14	TilTechnol             # TIL Technologies
00:08:15	Cats                   # CATS Co., Ltd.
00:08:16	Bluetags               # Bluetags A/S
00:08:17	Emergecore             # EmergeCore Networks LLC
00:08:18	Pixelworks             # Pixelworks, Inc.
00:08:19	Banksys
00:08:1A	SanradInte             # Sanrad Intelligence Storage Communications (2000) Ltd.
00:08:1B	Windigo                # Windigo Systems
00:08:1C	@PosCom                # @pos.com
00:08:1D	Ipsil                  # Ipsil, Incorporated
00:08:1E	Repeatit               # Repeatit AB
00:08:1F	PouYuenTec             # Pou Yuen Tech Corp. Ltd.
00:08:20	Cisco                  # Cisco Systems Inc.
00:08:21	Cisco                  # Cisco Systems Inc.
00:08:22	InproComm              # InPro Comm
00:08:23	Texa                   # Texa Corp.
00:08:24	PromatekIn             # Promatek Industries Ltd.
00:08:25	AcmePacket             # Acme Packet
00:08:26	ColoradoMe             # Colorado Med Tech
00:08:27	PirelliBro             # Pirelli Broadband Solutions
00:08:28	KoeiEngine             # Koei Engineering Ltd.
00:08:29	AvalNagasa             # Aval Nagasaki Corporation
00:08:2A	Powerwallz             # Powerwallz Network Security
00:08:2B	WooksungEl             # Wooksung Electronics, Inc.
00:08:2C	Homag                  # Homag AG
00:08:2D	IndusTeqsi             # Indus Teqsite Private Limited
00:08:2E	MultitoneE             # Multitone Electronics PLC
00:08:4E	Divergenet             # DivergeNet, Inc.
00:08:4F	Qualstar               # Qualstar Corporation
00:08:50	ArizonaIns             # Arizona Instrument Corp.
00:08:51	CanadianBa             # Canadian Bank Note Company, Ltd.
00:08:52	Davolink               # Davolink Co. Inc.
00:08:53	Schleicher             # Schleicher GmbH & Co. Relaiswerke KG
00:08:54	Netronix               # Netronix, Inc.
00:08:55	Nasa-Godda             # NASA-Goddard Space Flight Center
00:08:56	Gamatronic             # Gamatronic Electronic Industries Ltd.
00:08:57	PolarisNet             # Polaris Networks, Inc.
00:08:58	Novatechno             # Novatechnology Inc.
00:08:59	ShenzhenUn             # ShenZhen Unitone Electronics Co., Ltd.
00:08:5A	Intigate               # IntiGate Inc.
00:08:5B	HanbitElec             # Hanbit Electronics Co., Ltd.
00:08:5C	ShanghaiDa             # Shanghai Dare Technologies Co. Ltd.
00:08:5D	Aastra
00:08:5E	Pco                    # PCO AG
00:08:5F	PicanolNV              # Picanol N.V.
00:08:60	LodgenetEn             # LodgeNet Entertainment Corp.
00:08:61	Softenergy             # SoftEnergy Co., Ltd.
00:08:62	NecElumina             # NEC Eluminant Technologies, Inc.
00:08:63	Entrispher             # Entrisphere Inc.
00:08:64	FasySPA                # Fasy S.p.A.
00:08:65	Jascom                 # JASCOM CO., LTD
00:08:66	DsxAccess              # DSX Access Systems, Inc.
00:08:67	UptimeDevi             # Uptime Devices
00:08:68	Puroptix
00:08:69	Command-ET             # Command-e Technology Co.,Ltd.
00:08:6A	IndustrieT             # Industrie Technik IPS GmbH
00:08:6B	Mipsys
00:08:6C	PlasmonLms             # Plasmon LMS
00:08:6D	MissouriFr             # Missouri FreeNet
00:08:6E	Hyglo                  # Hyglo AB
00:08:6F	ResourcesC             # Resources Computer Network Ltd.
00:08:70	Rasvia                 # Rasvia Systems, Inc.
00:08:71	Northdata              # NORTHDATA Co., Ltd.
00:08:72	SorensonTe             # Sorenson Technologies, Inc.
00:08:73	DapDesignB             # DAP Design B.V.
00:08:74	DellComput             # Dell Computer Corp.
00:08:75	AcorpElect             # Acorp Electronics Corp.
00:08:76	Sdsystem
00:08:77	LiebertHir             # Liebert HIROSS S.p.A.
00:08:78	BenchmarkS             # Benchmark Storage Innovations
00:08:79	Cem                    # CEM Corporation
00:08:7A	Wipotec                # Wipotec GmbH
00:08:7B	RtxTelecom             # RTX Telecom A/S
00:08:7C	Cisco                  # Cisco Systems, Inc.
00:08:7D	Cisco                  # Cisco Systems Inc.
00:08:7E	BonElectro             # Bon Electro-Telecom Inc.
00:08:7F	SpaunElect             # SPAUN electronic GmbH & Co. KG
00:08:80	BroadtelCa             # BroadTel Canada Communications inc.
00:08:81	DigitalHan             # DIGITAL HANDS CO.,LTD.
00:08:82	Sigma                  # SIGMA CORPORATION
00:08:83	Hewlett-Pa             # Hewlett-Packard Company
00:08:84	IndexBrail             # Index Braille AB
00:08:85	EmsDrThoma             # EMS Dr. Thomas Wuensche
00:08:86	HansungTel             # Hansung Teliann, Inc.
00:08:87	Maschinenf             # Maschinenfabrik Reinhausen GmbH
00:08:88	OullimInfo             # OULLIM Information Technology Inc,.
00:08:89	EchostarTe             # Echostar Technologies Corp
00:08:8A	Minds@Work
00:08:8B	TropicNetw             # Tropic Networks Inc.
00:08:8C	QuantaNetw             # Quanta Network Systems Inc.
00:08:8D	Sigma-Link             # Sigma-Links Inc.
00:08:8E	NihonCompu             # Nihon Computer Co., Ltd.
00:08:8F	AdvancedDi             # ADVANCED DIGITAL TECHNOLOGY
00:08:90	AvilinksSa             # AVILINKS SA
00:08:91	Lyan                   # Lyan Inc.
00:08:92	EmSolution             # EM Solutions
00:08:93	LeInformat             # LE INFORMATION COMMUNICATION INC.
00:08:94	Innovision             # InnoVISION Multimedia Ltd.
00:08:95	DircTechno             # DIRC Technologie GmbH & Co.KG
00:08:96	Printronix             # Printronix, Inc.
00:08:97	QuakeTechn             # Quake Technologies
00:08:98	GigabitOpt             # Gigabit Optics Corporation
00:08:99	Netbind                # Netbind, Inc.
00:08:9A	AlcatelMic             # Alcatel Microelectronics
00:08:9B	IcpElectro             # ICP Electronics Inc.
00:08:9C	ElecsIndus             # Elecs Industry Co., Ltd.
00:08:9D	Uhd-Elektr             # UHD-Elektronik
00:08:9E	BeijingEnt             # Beijing Enter-Net co.LTD
00:08:9F	EfmNetwork             # EFM Networks
00:08:A0	StotzFeinm             # Stotz Feinmesstechnik GmbH
00:08:A1	CnetTechno             # CNet Technology Inc.
00:08:A2	AdiEnginee             # ADI Engineering, Inc.
00:08:A3	Cisco                  # Cisco Systems
00:08:A4	Cisco                  # Cisco Systems
00:08:A5	Peninsula              # Peninsula Systems Inc.
00:08:A6	MultiwareI             # Multiware & Image Co., Ltd.
00:08:A7	Ilogic                 # iLogic Inc.
00:08:A8	Systec                 # Systec Co., Ltd.
00:08:A9	SangsangTe             # SangSang Technology, Inc.
00:08:AA	Karam
00:08:AB	EnerlinxCo             # EnerLinx.com, Inc.
00:08:AC	Private
00:08:AD	Toyo-Linx              # Toyo-Linx Co., Ltd.
00:08:AE	Packetfron             # PacketFront Sweden AB
00:08:AF	Novatec                # Novatec Corporation
00:08:B0	BktelCommu             # BKtel communications GmbH
00:08:B1	Proquent               # ProQuent Systems
00:08:B2	ShenzhenCo             # SHENZHEN COMPASS TECHNOLOGY DEVELOPMENT CO.,LTD
00:08:B3	Fastwel
00:08:B4	Syspol
00:08:B5	TaiGuenEnt             # TAI GUEN ENTERPRISE CO., LTD
00:08:B6	Routefree              # RouteFree, Inc.
00:08:B7	Hit                    # HIT Incorporated
00:08:B8	EFJohnson              # E.F. Johnson
00:08:B9	KaonMedia              # KAON MEDIA Co., Ltd.
00:08:BA	Erskine                # Erskine Systems Ltd
00:08:BB	Netexcell
00:08:BC	Ilevo                  # Ilevo AB
00:08:BD	Tepg-Us
00:08:BE	XenpakMsaG             # XENPAK MSA Group
00:08:BF	AptusElekt             # Aptus Elektronik AB
00:08:C0	Asa                    # ASA SYSTEMS
00:08:C1	AvistarCom             # Avistar Communications Corporation
00:08:C2	Cisco                  # Cisco Systems
00:08:C3	Contex                 # Contex A/S
00:08:C4	Hikari                 # Hikari Co.,Ltd.
00:08:C5	Liontech               # Liontech Co., Ltd.
00:08:C6	PhilipsCon             # Philips Consumer Communications
00:08:C7	CompaqComp             # COMPAQ COMPUTER CORPORATION
00:08:C8	Soneticom              # Soneticom, Inc.
00:08:C9	TechnisatD             # TechniSat Digital GmbH
00:08:CA	TwinhanTec             # TwinHan Technology Co.,Ltd
00:08:CB	ZetaBroadb             # Zeta Broadband Inc.
00:08:CC	Remotec                # Remotec, Inc.
00:08:CD	With-Net               # With-Net Inc
00:08:CE	Ipmobilene             # IPMobileNet Inc.
00:08:CF	NipponKoei             # Nippon Koei Power Systems Co., Ltd.
00:08:D0	MusashiEng             # Musashi Engineering Co., LTD.
00:08:D1	Karel                  # KAREL INC.
00:08:D2	ZoomNetwor             # ZOOM Networks Inc.
00:08:D3	HerculesTe             # Hercules Technologies S.A.
00:08:D4	IneoquestT             # IneoQuest Technologies, Inc
00:08:D5	VanguardMa             # Vanguard Managed Solutions
00:08:D6	Hassnet                # HASSNET Inc.
00:08:D7	How                    # HOW CORPORATION
00:08:D8	DowkeyMicr             # Dowkey Microwave
00:08:D9	Mitadenshi             # Mitadenshi Co.,LTD
00:08:DA	SofawareTe             # SofaWare Technologies Ltd.
00:08:DB	Corrigent              # Corrigent Systems
00:08:DC	Wiznet
00:08:DD	TelenaComm             # Telena Communications, Inc.
00:08:DE	3up                    # 3UP Systems
00:08:DF	Alistel                # Alistel Inc.
00:08:E0	AtoTechnol             # ATO Technology Ltd.
00:08:E1	Barix                  # Barix AG
00:08:E2	Cisco                  # Cisco Systems
00:08:E3	Cisco                  # Cisco Systems
00:08:E4	Envenergy              # Envenergy Inc
00:08:E5	Idk                    # IDK Corporation
00:08:E6	Littlefeet
00:08:E7	ShiControl             # SHI ControlSystems,Ltd.
00:08:E8	ExcelMaste             # Excel Master Ltd.
00:08:E9	Nextgig
00:08:EA	MotionCont             # Motion Control Engineering, Inc
00:08:EB	Romwin                 # ROMWin Co.,Ltd.
00:08:EC	Zonu                   # Zonu, Inc.
00:08:ED	St&TInstru             # ST&T Instrument Corp.
00:08:EE	LogicProdu             # Logic Product Development
00:08:EF	DibalSA                # DIBAL,S.A.
00:08:F0	NextGenera             # Next Generation Systems, Inc.
00:08:F1	Voltaire
00:08:F2	C&STechnol             # C&S Technology
00:08:F3	Wany
00:08:F4	BluetakeTe             # Bluetake Technology Co., Ltd.
00:08:F5	Yestechnol             # YESTECHNOLOGY Co.,Ltd.
00:08:F6	SumitomoEl             # SUMITOMO ELECTRIC HIGHTECHS.co.,ltd.
00:08:F7	HitachiSem             # Hitachi Ltd, Semiconductor &amp; Integrated Circuits Gr
00:08:F8	Guardall               # Guardall Ltd
00:08:F9	Padcom                 # Padcom, Inc.
00:08:FA	KarlEBrink             # Karl E.Brinkmann GmbH
00:08:FB	Sonosite               # SonoSite, Inc.
00:08:FC	Gigaphoton             # Gigaphoton Inc.
00:08:FD	Bluekorea              # BlueKorea Co., Ltd.
00:08:FE	UnikC&C                # UNIK C&C Co.,Ltd.
00:08:FF	TrilogyBro             # Trilogy Broadcast (Holdings) Ltd
00:09:00	Tmt
00:09:01	ShenzhenSh             # Shenzhen Shixuntong Information & Technoligy Co
00:09:02	RedlineCom             # Redline Communications Inc.
00:09:03	Panasas                # Panasas, Inc
00:09:04	MondialEle             # MONDIAL electronic
00:09:05	ItecTechno             # iTEC Technologies Ltd.
00:09:06	EsteemNetw             # Esteem Networks
00:09:07	ChrysalisD             # Chrysalis Development
00:09:08	VtechTechn             # VTech Technology Corp.
00:09:09	TelenorCon             # Telenor Connect A/S
00:09:0A	SnedfarTec             # SnedFar Technology Co., Ltd.
00:09:0B	MtlInstrum             # MTL  Instruments PLC
00:09:0C	MayekawaMf             # Mayekawa Mfg. Co. Ltd.
00:09:0D	LeaderElec             # LEADER ELECTRONICS CORP.
00:09:0E	HelixTechn             # Helix Technology Inc.
00:09:0F	Fortinet               # Fortinet Inc.
00:09:10	SimpleAcce             # Simple Access Inc.
00:09:11	Cisco                  # Cisco Systems
00:09:12	Cisco                  # Cisco Systems
00:09:13	Systemk                # SystemK Corporation
00:09:14	Computrols             # COMPUTROLS INC.
00:09:15	Cas                    # CAS Corp.
00:09:16	ListmanHom             # Listman Home Technologies, Inc.
00:09:17	WemTechnol             # WEM Technology Inc
00:09:18	SamsungTec             # SAMSUNG TECHWIN CO.,LTD
00:09:19	MdsGateway             # MDS Gateways
00:09:1A	MacatOptic             # Macat Optics & Electronics Co., Ltd.
00:09:1B	DigitalGen             # Digital Generation Inc.
00:09:1C	Cachevisio             # CacheVision, Inc
00:09:1D	ProteamCom             # Proteam Computer Corporation
00:09:1E	FirstechTe             # Firstech Technology Corp.
00:09:1F	A&Amp;D                # A&amp;D Co., Ltd.
00:09:20	EpoxComput             # EpoX COMPUTER CO.,LTD.
00:09:21	PlanmecaOy             # Planmeca Oy
00:09:22	TouchlessS             # Touchless Sensor Technology AG
00:09:23	HeamanSyst             # Heaman System Co., Ltd
00:09:24	Telebau                # Telebau GmbH
00:09:25	VsnSysteme             # VSN Systemen BV
00:09:26	YodaCommun             # YODA COMMUNICATIONS, INC.
00:09:27	Toyokeiki              # TOYOKEIKI CO.,LTD.
00:09:28	Telecore               # Telecore Inc
00:09:29	SanyoIndus             # Sanyo Industries (UK) Limited
00:09:2A	Mytecs                 # MYTECS Co.,Ltd.
00:09:2B	IqstorNetw             # iQstor Networks, Inc.
00:09:2C	Hitpoint               # Hitpoint Inc.
00:09:2D	HighTechCo             # High Tech Computer, Corp.
00:09:2E	B&TechSyst             # B&Tech System Inc.
00:09:2F	AkomTechno             # Akom Technology Corporation
00:09:30	Aeroconcie             # AeroConcierge Inc.
00:09:31	FutureInte             # Future Internet, Inc.
00:09:32	Omnilux
00:09:33	Optovalley             # OPTOVALLEY Co. Ltd.
00:09:34	Dream-Mult             # Dream-Multimedia-Tv GmbH
00:09:35	Sandvine               # Sandvine Incorporated
00:09:36	Ipetronik              # Ipetronik GmbH & Co.KG
00:09:37	InventecAp             # Inventec Appliance Corp
00:09:38	AllotCommu             # Allot Communications
00:09:39	Shibasoku              # ShibaSoku Co.,Ltd.
00:09:3A	MolexFiber             # Molex Fiber Optics
00:09:3B	HyundaiNet             # HYUNDAI NETWORKS INC.
00:09:3C	JacquesTec             # Jacques Technologies P/L
00:09:3D	Newisys                # Newisys,Inc.
00:09:3E	C&ITechnol             # C&I Technologies
00:09:3F	Double-Win             # Double-Win Enterpirse CO., LTD
00:09:40	Agfeo                  # AGFEO GmbH & Co. KG
00:09:41	AlliedTele             # Allied Telesis K.K.
00:09:42	Cresco                 # CRESCO, LTD.
00:09:43	Cisco                  # Cisco Systems
00:09:44	Cisco                  # Cisco Systems
00:09:45	PalmmicroC             # Palmmicro Communications Inc
00:09:46	ClusterLab             # Cluster Labs GmbH
00:09:47	Aztek                  # Aztek, Inc.
00:09:48	VistaContr             # Vista Control Systems, Corp.
00:09:49	GlyphTechn             # Glyph Technologies Inc.
00:09:4A	HomenetCom             # Homenet Communications
00:09:4B	Fillfactor             # FillFactory NV
00:09:4C	Communicat             # Communication Weaver Co.,Ltd.
00:09:4D	BraintreeC             # Braintree Communications Pty Ltd
00:09:4E	BartechInt             # BARTECH SYSTEMS INTERNATIONAL, INC
00:09:4F	Elmegt                 # elmegt GmbH & Co. KG
00:09:50	Independen             # Independent Storage Corporation
00:09:51	ApogeeInst             # Apogee Instruments, Inc
00:09:52	Auerswald              # Auerswald GmbH & Co. KG
00:09:53	LinkageSys             # Linkage System Integration Co.Ltd.
00:09:54	AmitSpolSR             # AMiT spol. s. r. o.
00:09:55	YoungGener             # Young Generation International Corp.
00:09:56	NetworkGro             # Network Systems Group, Ltd. (NSG)
00:09:57	Supercalle             # Supercaller, Inc.
00:09:58	IntelnetSA             # INTELNET S.A.
00:09:59	Sitecsoft
00:09:5A	RacewoodTe             # RACEWOOD TECHNOLOGY
00:09:5B	Netgear                # Netgear, Inc.
00:09:5C	PhilipsMed             # Philips Medical Systems - Cardiac and Monitoring Systems (CM
00:09:5D	DialogueTe             # Dialogue Technology Corp.
00:09:5E	MasstechGr             # Masstech Group Inc.
00:09:5F	Telebyte               # Telebyte, Inc.
00:09:60	Yozan                  # YOZAN Inc.
00:09:61	Switchgear             # Switchgear and Instrumentation Ltd
00:09:62	FiletracAs             # Filetrac AS
00:09:63	DominionLa             # Dominion Lasercom Inc.
00:09:64	Hi-Techniq             # Hi-Techniques
00:09:65	Private
00:09:66	ThalesNavi             # Thales Navigation
00:09:67	Tachyon                # Tachyon, Inc
00:09:68	Technovent             # TECHNOVENTURE, INC.
00:09:69	MeretOptic             # Meret Optical Communications
00:09:6A	Cloverleaf             # Cloverleaf Communications Inc.
00:09:6B	Ibm                    # IBM Corporation
00:09:6C	ImediaSemi             # Imedia Semiconductor Corp.
00:09:6D	PowernetTe             # Powernet Technologies Corp.
00:09:6E	GiantElect             # GIANT ELECTRONICS LTD.
00:09:6F	BeijingZho             # Beijing Zhongqing Elegant Tech. Corp.,Limited
00:09:70	VibrationR             # Vibration Research Corporation
00:09:71	TimeManage             # Time Management, Inc.
00:09:72	Securebase             # Securebase,Inc
00:09:73	LentenTech             # Lenten Technology Co., Ltd.
00:09:74	InnopiaTec             # Innopia Technologies, Inc.
00:09:75	FsonaCommu             # fSONA Communications Corporation
00:09:76	DatasoftIs             # Datasoft ISDN Systems GmbH
00:09:77	BrunnerEle             # Brunner Elektronik AG
00:09:78	AijiSystem             # AIJI System Co., Ltd.
00:09:79	AdvancedTe             # Advanced Television Systems Committee, Inc.
00:09:7A	LouisDesig             # Louis Design Labs.
00:09:7B	Cisco                  # Cisco Systems
00:09:7C	Cisco                  # Cisco Systems
00:09:7D	SecwellNet             # SecWell Networks Oy
00:09:7E	ImiTechnol             # IMI TECHNOLOGY CO., LTD
00:09:7F	Vsecure200             # Vsecure 2000 LTD.
00:09:80	PowerZenit             # Power Zenith Inc.
00:09:81	NewportNet             # Newport Networks
00:09:82	LoeweOpta              # Loewe Opta GmbH
00:09:83	Gvision                # Gvision Incorporated
00:09:84	MycasaNetw             # MyCasa Network Inc.
00:09:85	AutoTeleco             # Auto Telecom Company
00:09:86	Metalink               # Metalink LTD.
00:09:87	NishiNippo             # NISHI NIPPON ELECTRIC WIRE & CABLE CO.,LTD.
00:09:88	NudianElec             # Nudian Electron Co., Ltd.
00:09:89	Vividlogic             # VividLogic Inc.
00:09:8A	Equallogic             # EqualLogic Inc
00:09:8B	EntropicCo             # Entropic Communications, Inc.
00:09:8C	OptionWire             # Option Wireless Sweden
00:09:8D	DctDigital             # DCT Ltd (Digital Communication Technologies Ltd)
00:09:8E	Ipcas                  # ipcas GmbH
00:09:8F	CetaceanNe             # Cetacean Networks
00:09:90	AcksysComm             # ACKSYS Communications & systems
00:09:91	GeFanucAut             # GE Fanuc Automation Manufacturing, Inc.
00:09:92	Interepoch             # InterEpoch Technology,INC.
00:09:93	Visteon                # Visteon Corporation
00:09:94	CronyxEngi             # Cronyx Engineering
00:09:95	CastleTech             # Castle Technology Ltd
00:09:96	Rdi
00:09:97	NortelNetw             # Nortel Networks
00:09:98	Capinfo                # Capinfo Company Limited
00:09:99	CpGeorgesR             # CP GEORGES RENAULT
00:09:9A	Elmo                   # ELMO COMPANY, LIMITED
00:09:9B	WesternTel             # Western Telematic Inc.
00:09:9C	NavalResea             # Naval Research Laboratory
00:09:9D	HaliplexCo             # Haliplex Communications
00:09:9E	Testech                # Testech, Inc.
00:09:9F	Videx                  # VIDEX INC.
00:09:A0	Microtechn             # Microtechno Corporation
00:09:A1	TelewiseCo             # Telewise Communications, Inc.
00:09:A2	Interface              # Interface Co., Ltd.
00:09:A3	LeadflyTec             # Leadfly Techologies Corp. Ltd.
00:09:A4	Hartec                 # HARTEC Corporation
00:09:A5	HansungEle             # HANSUNG ELETRONIC INDUSTRIES DEVELOPMENT CO., LTD
00:09:A6	IgnisOptic             # Ignis Optics, Inc.
00:09:A7	BangOlufse             # Bang & Olufsen A/S
00:09:A8	EastmodePt             # Eastmode Pte Ltd
00:09:A9	IkanosComm             # Ikanos Communications
00:09:AA	DataCommFo             # Data Comm for Business, Inc.
00:09:AB	Netcontrol             # Netcontrol Oy
00:09:AC	Lanvoice
00:09:AD	HyundaiSys             # HYUNDAI SYSCOMM, INC.
00:09:AE	OkanoElect             # OKANO ELECTRIC CO.,LTD
00:09:AF	E-Generis
00:09:B0	Onkyo                  # Onkyo Corporation
00:09:B1	KanematsuE             # Kanematsu Electronics, Ltd.
00:09:B2	L&F                    # L&F Inc.
00:09:B3	Mcm                    # MCM Systems Ltd
00:09:B4	KisanTelec             # KISAN TELECOM CO., LTD.
00:09:B5	3jTech                 # 3J Tech. Co., Ltd.
00:09:B6	Cisco                  # Cisco Systems
00:09:B7	Cisco                  # Cisco Systems
00:09:B8	Entise                 # Entise Systems
00:09:B9	ActionImag             # Action Imaging Solutions
00:09:BA	MakuInform             # MAKU Informationstechik GmbH
00:09:BB	Mathstar               # MathStar, Inc.
00:09:BC	Integrian              # Integrian, Inc.
00:09:BD	EpygiTechn             # Epygi Technologies, Ltd.
00:09:BE	Mamiya-Op              # Mamiya-OP Co.,Ltd.
00:09:BF	Nintendo               # Nintendo Co.,Ltd.
00:09:C0	6wind
00:09:C1	Proces-Dat             # PROCES-DATA A/S
00:09:C2	Private
00:09:C3	Netas
00:09:C4	Medicore               # Medicore Co., Ltd
00:09:C5	KingeneTec             # KINGENE Technology Corporation
00:09:C6	Visionics              # Visionics Corporation
00:09:C7	Movistec
00:09:C8	SinagawaTs             # SINAGAWA TSUSHIN KEISOU SERVICE
00:09:C9	Bluewinc               # BlueWINC Co., Ltd.
00:09:CA	Imaxnetwor             # iMaxNetworks(Shenzhen)Limited.
00:09:CB	Hbrain
00:09:CC	Moog                   # Moog GmbH
00:09:CD	HudsonSoft             # HUDSON SOFT CO.,LTD.
00:09:CE	Spacebridg             # SpaceBridge Semiconductor Corp.
00:09:CF	Iad                    # iAd GmbH
00:09:D0	VersatelNe             # Versatel Networks
00:09:D1	SeranoaNet             # SERANOA NETWORKS INC
00:09:D2	MaiLogic               # Mai Logic Inc.
00:09:D3	WesternDat             # Western DataCom Co., Inc.
00:09:D4	TranstechN             # Transtech Networks
00:09:D5	SignalComm             # Signal Communication, Inc.
00:09:D6	KncOne                 # KNC One GmbH
00:09:D7	DcSecurity             # DC Security Products
00:09:D8	Private
00:09:D9	Neoscale               # Neoscale Systems, Inc
00:09:DA	ControlMod             # Control Module Inc.
00:09:DB	Espace
00:09:DC	GalaxisTec             # Galaxis Technology AG
00:09:DD	MavinTechn             # Mavin Technology Inc.
00:09:DE	SamjinInfo             # Samjin Information & Communications Co., Ltd.
00:09:DF	VestelKomu             # Vestel Komunikasyon Sanayi ve Ticaret A.S.
00:09:E0	XemicsSA               # XEMICS S.A.
00:09:E1	GemtekTech             # Gemtek Technology Co., Ltd.
00:09:E2	SinbonElec             # Sinbon Electronics Co., Ltd.
00:09:E3	AngelIgles             # Angel Iglesias S.A.
00:09:E4	KTechInfos             # K Tech Infosystem Inc.
00:09:E5	HottingerB             # Hottinger Baldwin Messtechnik GmbH
00:09:E6	CyberSwitc             # Cyber Switching Inc.
00:09:E7	AdcTechono             # ADC Techonology
00:09:E8	Cisco                  # Cisco Systems
00:09:E9	Cisco                  # Cisco Systems
00:09:EA	Yem                    # YEM Inc.
00:09:EB	Humandata              # HuMANDATA LTD.
00:09:EC	Daktronics             # Daktronics, Inc.
00:09:ED	Cipheropti             # CipherOptics
00:09:EE	MeikyoElec             # MEIKYO ELECTRIC CO.,LTD
00:09:EF	VoceraComm             # Vocera Communications
00:09:F0	ShimizuTec             # Shimizu Technology Inc.
00:09:F1	YamakiElec             # Yamaki Electric Corporation
00:09:F2	CohuElectr             # Cohu, Inc., Electronics Division
00:09:F3	WellCommun             # WELL Communication Corp.
00:09:F4	AlconLabor             # Alcon Laboratories, Inc.
00:09:F5	EmersonNet             # Emerson Network Power Co.,Ltd
00:09:F6	ShenzhenEa             # Shenzhen Eastern Digital Tech Ltd.
00:09:F7	SedADivisi             # SED, a division of Calian
00:09:F8	UnimoTechn             # UNIMO TECHNOLOGY CO., LTD.
00:09:F9	ArtJapan               # ART JAPAN CO., LTD.
00:09:FB	PhilipsMed             # Philips Medizinsysteme Boeblingen GmbH
00:09:FC	Ipflex                 # IPFLEX Inc.
00:09:FD	Ubinetics              # Ubinetics Limited
00:09:FE	DaisyTechn             # Daisy Technologies, Inc.
00:09:FF	XNet2000               # X.net 2000 GmbH
00:0A:00	Mediatek               # Mediatek Corp.
00:0A:01	Sohoware               # SOHOware, Inc.
00:0A:02	Annso                  # ANNSO CO., LTD.
00:0A:03	EndesaServ             # ENDESA SERVICIOS, S.L.
00:0A:04	3comEurope             # 3Com Europe Ltd
00:0A:05	Widax                  # Widax Corp.
00:0A:06	TeledexLlc             # Teledex LLC
00:0A:07	Webwayone              # WebWayOne Ltd
00:0A:08	AlpineElec             # ALPINE ELECTRONICS, INC.
00:0A:09	TaracomInt             # TaraCom Integrated Products, Inc.
00:0A:0A	Sunix                  # SUNIX Co., Ltd.
00:0A:0B	Sealevel               # Sealevel Systems, Inc.
00:0A:0C	Scientific             # Scientific Research Corporation
00:0A:0D	Mergeoptic             # MergeOptics GmbH
00:0A:0E	InvivoRese             # Invivo Research Inc.
00:0A:0F	IlryungTel             # Ilryung Telesys, Inc
00:0A:10	FastMediaI             # FAST media integrations AG
00:0A:11	ExpetTechn             # ExPet Technologies, Inc
00:0A:12	AzylexTech             # Azylex Technology, Inc
00:0A:13	SilentWitn             # Silent Witness
00:0A:14	TecoAS                 # TECO a.s.
00:0A:15	SiliconDat             # Silicon Data, Inc
00:0A:16	LassenRese             # Lassen Research
00:0A:17	NestarComm             # NESTAR COMMUNICATIONS, INC
00:0A:18	Vichel                 # Vichel Inc.
00:0A:19	ValerePowe             # Valere Power, Inc.
00:0A:1A	Imerge                 # Imerge Ltd
00:0A:1B	StreamLabs             # Stream Labs
00:0A:1C	BridgeInfo             # Bridge Information Co., Ltd.
00:0A:1D	OpticalCom             # Optical Communications Products Inc.
00:0A:1E	Red-MProdu             # Red-M Products Limited
00:0A:1F	ArtWareTel             # ART WARE Telecommunication Co., Ltd.
00:0A:20	SvaNetwork             # SVA Networks, Inc.
00:0A:21	IntegraTel             # Integra Telecom Co. Ltd
00:0A:22	Amperion               # Amperion Inc
00:0A:23	ParamaNetw             # Parama Networks Inc
00:0A:24	OctaveComm             # Octave Communications
00:0A:25	CeragonNet             # CERAGON NETWORKS
00:0A:26	CeiaSPA                # CEIA S.p.A.
00:0A:27	AppleCompu             # Apple Computer, Inc.
00:0A:28	Motorola
00:0A:29	PanDacomNe             # Pan Dacom Networking AG
00:0A:2A	Qsi                    # QSI Systems Inc.
00:0A:2B	Etherstuff
00:0A:2C	ActiveTchn             # Active Tchnology Corporation
00:0A:2D	Private
00:0A:2E	MapleNetwo             # MAPLE NETWORKS CO., LTD
00:0A:2F	Artnix                 # Artnix Inc.
00:0A:30	JohnsonCon             # Johnson Controls-ASG
00:0A:31	HcvWireles             # HCV Wireless
00:0A:32	Xsido                  # Xsido Corporation
00:0A:33	SierraLogi             # Sierra Logic, Inc.
00:0A:34	Identicard             # Identicard Systems Incorporated
00:0A:35	Xilinx
00:0A:36	SynelecTel             # Synelec Telecom Multimedia
00:0A:37	ProceraNet             # Procera Networks, Inc.
00:0A:38	NetlockTec             # Netlock Technologies, Inc.
00:0A:39	LopaInform             # LoPA Information Technology
00:0A:3A	J-ThreeInt             # J-THREE INTERNATIONAL Holding Co., Ltd.
00:0A:3B	GctSemicon             # GCT Semiconductor, Inc
00:0A:3C	Enerpoint              # Enerpoint Ltd.
00:0A:3D	EloSistema             # Elo Sistemas Eletronicos S.A.
00:0A:3E	EadsTeleco             # EADS Telecom
00:0A:3F	DataEast               # Data East Corporation
00:0A:40	CrownAudio             # Crown Audio
00:0A:41	Cisco                  # Cisco Systems
00:0A:42	Cisco                  # Cisco Systems
00:0A:43	ChunghwaTe             # Chunghwa Telecom Co., Ltd.
00:0A:44	AveryDenni             # Avery Dennison Deutschland GmbH
00:0A:45	Audio-Tech             # Audio-Technica Corp.
00:0A:46	AroControl             # ARO Controls SAS
00:0A:47	AlliedVisi             # Allied Vision Technologies
00:0A:48	AlbatronTe             # Albatron Technology
00:0A:49	AcopiaNetw             # Acopia Networks
00:0A:4A	Targa                  # Targa Systems Ltd.
00:0A:4B	DatapowerT             # DataPower Technology, Inc.
00:0A:4C	MolecularD             # Molecular Devices Corporation
00:0A:4D	Noritz                 # Noritz Corporation
00:0A:4E	UnitekElec             # UNITEK Electronics INC.
00:0A:4F	BrainBoxes             # Brain Boxes Limited
00:0A:50	Remotek                # REMOTEK CORPORATION
00:0A:51	Gyrosignal             # GyroSignal Technology Co., Ltd.
00:0A:52	Asiarf                 # AsiaRF Ltd.
00:0A:53	Intronics              # Intronics, Incorporated
00:0A:54	LagunaHill             # Laguna Hills, Inc.
00:0A:55	Markem                 # MARKEM Corporation
00:0A:56	HitachiMax             # HITACHI Maxell Ltd.
00:0A:57	Hewlett-Pa             # Hewlett-Packard Company - Standards
00:0A:58	Ingenieur-             # Ingenieur-Buero Freyer & Siegel
00:0A:59	HwServer               # HW server
00:0A:5A	GreennetTe             # GreenNET Technologies Co.,Ltd.
00:0A:5B	Power-OneA             # Power-One as
00:0A:5C	CarelSPA               # Carel s.p.a.
00:0A:5D	PucFounder             # PUC Founder (MSC) Berhad
00:0A:5E	3com                   # 3COM Corporation
00:0A:5F	Almedio                # almedio inc.
00:0A:60	AutostarTe             # Autostar Technology Pte Ltd
00:0A:61	Cellinx                # Cellinx Systems Inc.
00:0A:62	CrinisNetw             # Crinis Networks, Inc.
00:0A:63	Dhd                    # DHD GmbH
00:0A:64	EracomTech             # Eracom Technologies
00:0A:65	Gentechmed             # GentechMedia.co.,ltd.
00:0A:66	Mitsubishi             # MITSUBISHI ELECTRIC SYSTEM & SERVICE CO.,LTD.
00:0A:67	Ongcorp
00:0A:68	Solarflare             # SolarFlare Communications, Inc.
00:0A:69	SunnyBellT             # SUNNY bell Technology Co., Ltd.
00:0A:6A	SvmMicrowa             # SVM Microwaves s.r.o.
00:0A:6B	TadiranTel             # Tadiran Telecom Business Systems LTD
00:0A:6C	Walchem                # Walchem Corporation
00:0A:6D	EksElektro             # EKS Elektronikservice GmbH
00:0A:6E	BroadcastT             # Broadcast Technology Limited
00:0A:6F	ZyflexTech             # ZyFLEX Technologies Inc
00:0A:70	MplsForum              # MPLS Forum
00:0A:71	AvrioTechn             # Avrio Technologies, Inc
00:0A:72	Simpletech             # SimpleTech, Inc.
00:0A:73	Scientific             # Scientific Atlanta
00:0A:74	ManticomNe             # Manticom Networks Inc.
00:0A:75	CatElectro             # Cat Electronics
00:0A:76	BeidaJadeB             # Beida Jade Bird Huaguang Technology Co.,Ltd
00:0A:77	BluewireTe             # Bluewire Technologies LLC
00:0A:78	Olitec
00:0A:79	CoregaKK               # corega K.K.
00:0A:7A	KyoritsuEl             # Kyoritsu Electric Co., Ltd.
00:0A:7B	CorneliusC             # Cornelius Consult
00:0A:7C	Tecton                 # Tecton Ltd
00:0A:7D	Valo                   # Valo, Inc.
00:0A:7E	AdvantageG             # The Advantage Group
00:0A:7F	TeradonInd             # Teradon Industries, Inc
00:0A:80	Telkonet               # Telkonet Inc.
00:0A:81	TeimaAudio             # TEIMA Audiotex S.L.
00:0A:82	TatsutaSys             # TATSUTA SYSTEM ELECTRONICS CO.,LTD.
00:0A:83	SaltoSL                # SALTO SYSTEMS S.L.
00:0A:84	RainsunEnt             # Rainsun Enterprise Co., Ltd.
00:0A:85	PlatC2                 # PLAT'C2,Inc
00:0A:86	Lenze
00:0A:87	Integrated             # Integrated Micromachines Inc.
00:0A:88	IncypherSA             # InCypher S.A.
00:0A:89	Creval                 # Creval Systems, Inc.
00:0A:8A	Cisco                  # Cisco Systems
00:0A:8B	Cisco                  # Cisco Systems
00:0A:8C	Guardware              # Guardware Systems Ltd.
00:0A:8D	Eurotherm              # EUROTHERM LIMITED
00:0A:8E	Invacom                # Invacom Ltd
00:0A:8F	AskaIntern             # Aska International Inc.
00:0A:90	BaysideInt             # Bayside Interactive, Inc.
00:0A:91	Hemocue                # HemoCue AB
00:0A:92	Presonus               # Presonus Corporation
00:0A:93	W2Networks             # W2 Networks, Inc.
00:0A:94	ShanghaiCe             # ShangHai cellink CO., LTD
00:0A:95	AppleCompu             # Apple Computer, Inc.
00:0A:96	MewtelTech             # MEWTEL TECHNOLOGY INC.
00:0A:97	Sonicblue              # SONICblue, Inc.
00:0A:98	M+FGwinner             # M+F Gwinner GmbH & Co
00:0A:99	Dataradio              # Dataradio Inc.
00:0A:9A	AiptekInte             # Aiptek International Inc
00:0A:9B	TowaMeccs              # Towa Meccs Corporation
00:0A:9C	ServerTech             # Server Technology, Inc.
00:0A:9D	KingYoungT             # King Young Technology Co. Ltd.
00:0A:9E	BroadwebCo             # BroadWeb Corportation
00:0A:9F	PannawayTe             # Pannaway Technologies, Inc.
00:0A:A0	CedarPoint             # Cedar Point Communications
00:0A:A1	VVS                    # V V S Limited
00:0A:A2	Systek                 # SYSTEK INC.
00:0A:A3	ShimafujiE             # SHIMAFUJI ELECTRIC CO.,LTD.
00:0A:A4	ShanghaiSu             # SHANGHAI SURVEILLANCE TECHNOLOGY CO,LTD
00:0A:A5	MaxlinkInd             # MAXLINK INDUSTRIES LIMITED
00:0A:A6	Hochiki                # Hochiki Corporation
00:0A:A7	Fei                    # FEI Company
00:0A:A8	EpipePty               # ePipe Pty. Ltd.
00:0A:A9	BrooksAuto             # Brooks Automation GmbH
00:0A:AA	AltigenCom             # AltiGen Communications Inc.
00:0A:AB	ToyotaMacs             # TOYOTA MACS, INC.
00:0A:AC	TerratecEl             # TerraTec Electronic GmbH
00:0A:AD	Stargames              # Stargames Corporation
00:0A:AE	RosemountP             # Rosemount Process Analytical
00:0A:AF	Pipal                  # Pipal Systems
00:0A:B0	LoytecElec             # LOYTEC electronics GmbH
00:0A:B1	Genetec                # GENETEC Corporation
00:0A:B2	FresnelWir             # Fresnel Wireless Systems
00:0A:B3	FaGira                 # Fa. GIRA
00:0A:B4	EticTeleco             # ETIC Telecommunications
00:0A:B5	DigitalEle             # Digital Electronic Network
00:0A:B6	Compunetix             # COMPUNETIX, INC
00:0A:B7	Cisco                  # Cisco Systems
00:0A:B8	Cisco                  # Cisco Systems
00:0A:B9	AsteraTech             # Astera Technologies Corp.
00:0A:BA	ArconTechn             # Arcon Technology Limited
00:0A:BB	TaiwanSeco             # Taiwan Secom Co,. Ltd
00:0A:BC	Seabridge              # Seabridge Ltd.
00:0A:BD	RupprechtP             # Rupprecht & Patashnick Co.
00:0A:BE	OpnetTechn             # OPNET Technologies CO., LTD.
00:0A:BF	HirotaSs               # HIROTA SS
00:0A:C0	FuyohVideo             # Fuyoh Video Industry CO., LTD.
00:0A:C1	Futuretel
00:0A:C2	FiberhomeT             # FiberHome Telecommunication Technologies CO.,LTD
00:0A:C3	EmTechnics             # eM Technics Co., Ltd.
00:0A:C4	DaewooTele             # Daewoo Teletech Co., Ltd
00:0A:C5	ColorKinet             # Color Kinetics
00:0A:C6	CeterusNet             # Ceterus Networks, Inc.
00:0A:C7	UnicationG             # Unication Group
00:0A:C8	ZpsysPlann             # ZPSYS CO.,LTD. (Planning&Management)
00:0A:C9	Zambeel                # Zambeel Inc
00:0A:CA	YokoyamaSh             # YOKOYAMA SHOKAI CO.,Ltd.
00:0A:CB	XpakMsaGro             # XPAK MSA Group
00:0A:CC	WinnowNetw             # Winnow Networks, Inc.
00:0A:CD	SunrichTec             # Sunrich Technology Limited
00:0A:CE	Radiantech             # RADIANTECH, INC.
00:0A:CF	ProvideoMu             # PROVIDEO Multimedia Co. Ltd.
00:0A:D0	NiigataDev             # Niigata Develoment Center,  F.I.T. Co., Ltd.
00:0A:D1	Mws
00:0A:D2	Jepico                 # JEPICO Corporation
00:0A:D3	Initech                # INITECH Co., Ltd
00:0A:D4	Corebell               # CoreBell Systems Inc.
00:0A:D5	Brainchild             # Brainchild Electronic Co., Ltd.
00:0A:D6	BeamreachN             # BeamReach Networks
00:0A:D7	OriginElec             # Origin ELECTRIC CO.,LTD.
00:0A:D8	IpcservTec             # IPCserv Technology Corp.
00:0A:D9	SonyEricss             # Sony Ericsson Mobile Communications AB
00:0A:DA	Private
00:0A:DB	SkypilotNe             # SkyPilot Network, Inc
00:0A:DC	Ruggedcom              # RuggedCom Inc.
00:0A:DD	InscitekMi             # InSciTek Microsystems, Inc.
00:0A:DE	HappyCommu             # Happy Communication Co., Ltd.
00:0A:DF	Gennum                 # Gennum Corporation
00:0A:E0	FujitsuSof             # Fujitsu Softek
00:0A:E1	EgTechnolo             # EG Technology
00:0A:E2	BinatoneEl             # Binatone Electronics International, Ltd
00:0A:E3	YangMeiTec             # YANG MEI TECHNOLOGY CO., LTD
00:0A:E4	Wistron                # Wistron Corp.
00:0A:E5	Scottcare              # ScottCare Corporation
00:0A:E6	Elitegroup             # Elitegroup Computer System Co. (ECS)
00:0A:E7	EliopSA                # ELIOP S.A.
00:0A:E8	CathayRoxu             # Cathay Roxus Information Technology Co. LTD
00:0A:E9	AirvastTec             # AirVast Technology Inc.
00:0A:EA	AdamElektr             # ADAM ELEKTRONIK LTD.STI.
00:0A:EB	ShenzhenTp             # Shenzhen Tp-Link Technology Co; Ltd.
00:0A:EC	KoatsuGasK             # Koatsu Gas Kogyo Co., Ltd.
00:0A:ED	HartingVen             # HARTING Vending G.m.b.H. & CO KG
00:0A:EE	GcdHard-So             # GCD Hard- & Software GmbH
00:0A:EF	OtrumAsa               # OTRUM ASA
00:0A:F0	Shin-OhEle             # SHIN-OH ELECTRONICS CO., LTD. R&D
00:0A:F1	ClarityDes             # Clarity Design, Inc.
00:0A:F2	Neoaxiom               # NeoAxiom Corp.
00:0A:F3	Cisco                  # Cisco Systems
00:0A:F4	Cisco                  # Cisco Systems
00:0A:F5	AirgoNetwo             # Airgo Networks, Inc.
00:0A:F6	ComputerPr             # Computer Process Controls
00:0A:F7	Broadcom               # Broadcom Corp.
00:0A:F8	AmericanTe             # American Telecare Inc.
00:0A:F9	Hiconnect              # HiConnect, Inc.
00:0A:FA	TraverseTe             # Traverse Technologies Australia
00:0A:FB	Ambri                  # Ambri Limited
00:0A:FC	CoreTecCom             # Core Tec Communications, LLC
00:0A:FD	VikingElec             # Viking Electronic Services
00:0A:FE	Novapal                # NovaPal Ltd
00:0A:FF	KilchherrE             # Kilchherr Elektronik AG
00:0B:00	FujianStar             # FUJIAN START COMPUTER EQUIPMENT CO.,LTD
00:0B:01	DaiichiEle             # DAIICHI ELECTRONICS CO., LTD.
00:0B:02	DallmeierE             # Dallmeier electronic
00:0B:03	TaekwangIn             # Taekwang Industrial Co., Ltd
00:0B:04	Volktek                # Volktek Corporation
00:0B:05	PacificBro             # Pacific Broadband Networks
00:0B:06	MotorolaBc             # Motorola BCS
00:0B:07	VoxpathNet             # Voxpath Networks
00:0B:08	PillarData             # Pillar Data Systems
00:0B:09	IfoundrySi             # Ifoundry Systems Singapore
00:0B:0A	DbmOptics              # dBm Optics
00:0B:0B	Corrent                # Corrent Corporation
00:0B:0C	Agile                  # Agile Systems Inc.
00:0B:0D	Air2u                  # Air2U, Inc.
00:0B:0E	TrapezeNet             # Trapeze Networks
00:0B:0F	NyquistInd             # Nyquist Industrial Control BV
00:0B:10	11waveTech             # 11wave Technonlogy Co.,Ltd
00:0B:11	HimejiAbcT             # HIMEJI ABC TRADING CO.,LTD.
00:0B:12	NuriTeleco             # NURI Telecom Co., Ltd.
00:0B:13	Zetron                 # ZETRON INC
00:0B:14	Viewsonic              # ViewSonic Corporation
00:0B:15	PlatypusTe             # Platypus Technology
00:0B:16	Communicat             # Communication Machinery Corporation
00:0B:17	MksInstrum             # MKS Instruments
00:0B:18	Private
00:0B:19	VernierNet             # Vernier Networks, Inc.
00:0B:1A	Teltone                # Teltone Corporation
00:0B:1B	Systronix              # Systronix, Inc.
00:0B:1C	SibcoBv                # SIBCO bv
00:0B:1D	LayerzeroP             # LayerZero Power Systems, Inc.
00:0B:1E	KappaOpto-             # KAPPA opto-electronics GmbH
00:0B:1F	IConComput             # I CON Computer Co.
00:0B:20	Hirata                 # Hirata corporation
00:0B:21	G-StarComm             # G-Star Communications Inc.
00:0B:22	Environmen             # Environmental Systems and Services
00:0B:23	SiemensSub             # Siemens Subscriber Networks
00:0B:24	Airlogic
00:0B:25	Aeluros
00:0B:26	Wetek                  # Wetek Corporation
00:0B:27	Scion                  # Scion Corporation
00:0B:28	Quatech                # Quatech Inc.
00:0B:29	LgIndustri             # LG Industrial Systems Co.,Ltd.
00:0B:2A	Howtel                 # HOWTEL Co., Ltd.
00:0B:2B	Hostnet                # HOSTNET CORPORATION
00:0B:2C	EikiIndust             # Eiki Industrial Co. Ltd.
00:0B:2D	Danfoss                # Danfoss Inc.
00:0B:2E	Cal-CompEl             # Cal-Comp Electronics (Thailand) Public Company Limited Taipe
00:0B:2F	Bplan                  # bplan GmbH
00:0B:30	BeijingGon             # Beijing Gongye Science & Technology Co.,Ltd
00:0B:31	YantaiZhiy             # Yantai ZhiYang Scientific and technology industry CO., LTD
00:0B:32	Vormetric              # VORMETRIC, INC.
00:0B:33	Vivato
00:0B:34	ShanghaiBr             # ShangHai Broadband Technologies CO.LTD
00:0B:35	QuadBitSys             # Quad Bit System co., Ltd.
00:0B:36	Productivi             # Productivity Systems, Inc.
00:0B:37	Manufactur             # MANUFACTURE DES MONTRES ROLEX SA
00:0B:38	Knuerr                 # Knuerr AG
00:0B:39	KeisokuGik             # Keisoku Giken Co.,Ltd.
00:0B:3A	FortelDtv              # Fortel DTV, Inc.
00:0B:3B	Devolo                 # devolo AG
00:0B:3C	CygnalInte             # Cygnal Integrated Products, Inc.
00:0B:3D	ContalOk               # CONTAL OK Ltd.
00:0B:3E	Bittware               # BittWare, Inc
00:0B:3F	AnthologyS             # Anthology Solutions Inc.
00:0B:40	Opnext                 # OpNext Inc.
00:0B:41	IngBueroDr             # Ing. Buero Dr. Beutlhauser
00:0B:42	Commax                 # commax Co., Ltd.
00:0B:43	Microscan              # Microscan Systems, Inc.
00:0B:44	ConcordIde             # Concord IDea Corp.
00:0B:45	Cisco
00:0B:46	Cisco
00:0B:47	AdvancedEn             # Advanced Energy
00:0B:48	Sofrel
00:0B:49	Rf-LinkSys             # RF-Link System Inc.
00:0B:4A	Visimetric             # Visimetrics (UK) Ltd
00:0B:4B	VisiowaveS             # VISIOWAVE SA
00:0B:4C	ClarionMSd             # Clarion (M) Sdn Bhd
00:0B:4D	Emuzed
00:0B:4E	VertexrsiA             # VertexRSI Antenna Products Division
00:0B:4F	Verifone               # Verifone, INC.
00:0B:50	Oxygnet
00:0B:51	MicetekInt             # Micetek International Inc.
00:0B:52	JoymaxElec             # JOYMAX ELECTRONICS CORP.
00:0B:53	Initium                # INITIUM Co., Ltd.
00:0B:54	BitmicroNe             # BiTMICRO Networks, Inc.
00:0B:55	Adinstrume             # ADInstruments
00:0B:56	Cybernetic             # Cybernetics
00:0B:57	SiliconLab             # Silicon Laboratories
00:0B:58	Astronauti             # Astronautics C.A  LTD
00:0B:59	ScriptproL             # ScriptPro, LLC
00:0B:5A	Hyperedge
00:0B:5B	RinconRese             # Rincon Research Corporation
00:0B:5C	Newtech                # Newtech Co.,Ltd
00:0B:5D	Fujitsu                # FUJITSU LIMITED
00:0B:5E	AudioEngin             # Audio Engineering Society Inc.
00:0B:5F	Cisco                  # Cisco Systems
00:0B:60	Cisco                  # Cisco Systems
00:0B:61	FriedrichL             # Friedrich L�tze GmbH &Co.
00:0B:62	Ingenieurb             # Ingenieurb�ro Ingo Mohnen
00:0B:63	Kaleidesca             # Kaleidescape
00:0B:64	KiebackPet             # Kieback & Peter GmbH & Co KG
00:0B:65	SyACSrl                # Sy.A.C. srl
00:0B:66	TeralinkCo             # Teralink Communications
00:0B:67	TopviewTec             # Topview Technology Corporation
00:0B:68	AddvalueCo             # Addvalue Communications Pte Ltd
00:0B:69	FrankeFinl             # Franke Finland Oy
00:0B:6A	AsiarockIn             # Asiarock Incorporation
00:0B:6B	WistronNew             # Wistron Neweb Corp.
00:0B:6C	Sychip                 # Sychip Inc.
00:0B:6D	SolectronJ             # SOLECTRON JAPAN NAKANIIDA
00:0B:6E	NeffInstru             # Neff Instrument Corp.
00:0B:6F	MediaStrea             # Media Streaming Networks Inc
00:0B:70	LoadTechno             # Load Technology, Inc.
00:0B:71	Litchfield             # Litchfield Communications Inc.
00:0B:72	Lawo                   # Lawo AG
00:0B:73	KodeosComm             # Kodeos Communications
00:0B:74	KingwaveTe             # Kingwave Technology Co., Ltd.
00:0B:75	Iosoft                 # Iosoft Ltd.
00:0B:76	Et&T                   # ET&T Co. Ltd.
00:0B:77	Cogent                 # Cogent Systems, Inc.
00:0B:78	Taifatech              # TAIFATECH INC.
00:0B:79	X-Com                  # X-COM, Inc.
00:0B:7A	WaveScienc             # Wave Science Inc.
00:0B:7B	Test-Um                # Test-Um Inc.
00:0B:7C	TelexCommu             # Telex Communications
00:0B:7D	SolomonExt             # SOLOMON EXTREME INTERNATIONAL LTD.
00:0B:7E	Saginomiya             # SAGINOMIYA Seisakusho Inc.
00:0B:7F	Omniwerks
00:0B:80	LyciumNetw             # Lycium Networks
00:0B:81	Kaparel                # Kaparel Corporation
00:0B:82	Grandstrea             # Grandstream Networks, Inc.
00:0B:83	DatawattBV             # DATAWATT B.V.
00:0B:84	Bodet
00:0B:85	Airespace              # Airespace, Inc.
00:0B:86	ArubaNetwo             # Aruba Networks
00:0B:87	AmericanRe             # American Reliance Inc.
00:0B:88	Vidisco                # Vidisco ltd.
00:0B:89	TopGlobalT             # Top Global Technology, Ltd.
00:0B:8A	Miteq                  # MITEQ Inc.
00:0B:8B	KerajetSA              # KERAJET, S.A.
00:0B:8C	Flextronic             # flextronics israel
00:0B:8D	AvvioNetwo             # Avvio Networks
00:0B:8E	Ascent                 # Ascent Corporation
00:0B:8F	AkitaElect             # AKITA ELECTRONICS SYSTEMS CO.,LTD.
00:0B:90	CovaroNetw             # Covaro Networks, Inc.
00:0B:91	AglaiaGese             # Aglaia Gesellschaft f�r Bildverarbeitung und Kommunikation m
00:0B:92	AscomDanma             # Ascom Danmark A/S
00:0B:93	BarmagElec             # Barmag Electronic
00:0B:94	DigitalMon             # Digital Monitoring Products, Inc.
00:0B:95	EbetGaming             # eBet Gaming Systems Pty Ltd
00:0B:96	InnotracDi             # Innotrac Diagnostics Oy
00:0B:97	Matsushita             # Matsushita Electric Industrial Co.,Ltd.
00:0B:98	Nicetechvi             # NiceTechVision
00:0B:99	SensableTe             # SensAble Technologies, Inc.
00:0B:9A	ShanghaiUl             # Shanghai Ulink Telecom Equipment Co. Ltd.
00:0B:9B	SiriusSyst             # Sirius System Co, Ltd.
00:0B:9C	TribeamTec             # TriBeam Technologies, Inc.
00:0B:9D	TwinmosTec             # TwinMOS Technologies Inc.
00:0B:9E	YasingTech             # Yasing Technology Corp.
00:0B:9F	NeueElsa               # Neue ELSA GmbH
00:0B:A0	T&LInforma             # T&L Information Inc.
00:0B:A1	Syscom                 # SYSCOM Ltd.
00:0B:A2	SumitomoEl             # Sumitomo Electric Networks, Inc
00:0B:A3	SiemensI&S             # Siemens AG, I&S
00:0B:A4	ShironSate             # Shiron Satellite Communications Ltd. (1996)
00:0B:A5	QuasarCipt             # Quasar Cipta Mandiri, PT
00:0B:A6	MiyakawaEl             # Miyakawa Electric Works Ltd.
00:0B:A7	MarantiNet             # Maranti Networks
00:0B:A8	HanbackEle             # HANBACK ELECTRONICS CO., LTD.
00:0B:A9	Cloudshiel             # CloudShield Technologies, Inc.
00:0B:AA	Aiphone                # Aiphone co.,Ltd
00:0B:AB	AdvantechT             # Advantech Technology (CHINA) Co., Ltd.
00:0B:AC	3comEurope             # 3Com Europe Ltd.
00:0B:AD	Pc-Pos                 # PC-PoS Inc.
00:0B:AE	VitalsSyst             # Vitals System Inc.
00:0B:AF	WoojuCommu             # WOOJU COMMUNICATIONS Co,.Ltd
00:0B:B0	SysnetTele             # Sysnet Telematica srl
00:0B:B1	SuperStarT             # Super Star Technology Co., Ltd.
00:0B:B2	SmallbigTe             # SMALLBIG TECHNOLOGY
00:0B:B3	RitTechnol             # RiT technologies Ltd.
00:0B:B4	RdcSemicon             # RDC Semiconductor Inc.,
00:0B:B5	NstorTechn             # nStor Technologies, Inc.
00:0B:B6	Mototech               # Mototech Inc.
00:0B:B7	Micro                  # Micro Systems Co.,Ltd.
00:0B:B8	KihokuElec             # Kihoku Electronic Co.
00:0B:B9	Imsys                  # Imsys AB
00:0B:BA	HarmonicBr             # Harmonic Broadband Access Networks
00:0B:BB	Etin                   # Etin Systems Co., Ltd
00:0B:BC	EnGarde                # En Garde Systems, Inc.
00:0B:BD	Connexionz             # Connexionz Limited
00:0B:BE	Cisco                  # Cisco Systems
00:0B:BF	Cisco                  # Cisco Systems
00:0B:C0	ChinaIwnco             # China IWNComm Co., Ltd.
00:0B:C1	BayMicrosy             # Bay Microsystems, Inc.
00:0B:C2	CorinexCom             # Corinex Communication Corp.
00:0B:C3	Multiplex              # Multiplex, Inc.
00:0B:C4	Biotronik              # BIOTRONIK GmbH & Co
00:0B:C5	SmcNetwork             # SMC Networks, Inc.
00:0B:C6	Isac                   # ISAC, Inc.
00:0B:C7	IcetSPA                # ICET S.p.A.
00:0B:C8	AirflowNet             # AirFlow Networks
00:0B:C9	Electrolin             # Electroline Equipment
00:0B:CA	DatavanInt             # DATAVAN International Corporation
00:0B:CB	FagorAutom             # Fagor Automation , S. Coop
00:0B:CC	JusanSA                # JUSAN, S.A.
00:0B:CD	CompaqHp               # Compaq (HP)
00:0B:CE	Free2move              # Free2move AB
00:0B:CF	AgfaNdt                # AGFA NDT INC.
00:0B:D0	XimetaTech             # XiMeta Technology Americas Inc.
00:0B:D1	Aeronix                # Aeronix, Inc.
00:0B:D2	RemoproTec             # Remopro Technology Inc.
00:0B:D3	Cd3o
00:0B:D4	BeijingWis             # Beijing Wise Technology & Science Development Co.Ltd
00:0B:D5	Nvergence              # Nvergence, Inc.
00:0B:D6	PaxtonAcce             # Paxton Access Ltd
00:0B:D7	MbbGelma               # MBB Gelma GmbH
00:0B:D8	Industrial             # Industrial Scientific Corp.
00:0B:D9	GeneralHyd             # General Hydrogen
00:0B:DA	Eyecross               # EyeCross Co.,Inc.
00:0B:DB	DellEsgPcb             # Dell ESG PCBA Test
00:0B:DC	Akcp
00:0B:DD	TohokuRico             # TOHOKU RICOH Co., LTD.
00:0B:DE	Teldix                 # TELDIX GmbH
00:0B:DF	ShenzhenRo             # Shenzhen RouterD Networks Limited
00:0B:E0	Serconet               # SercoNet Ltd.
00:0B:E1	NokiaNetPr             # Nokia NET Product Operations
00:0B:E2	Lumenera               # Lumenera Corporation
00:0B:E3	KeyStream              # Key Stream Co., Ltd.
00:0B:E4	Hosiden                # Hosiden Corporation
00:0B:E5	HimsKorea              # HIMS Korea Co., Ltd.
00:0B:E6	DatelElect             # Datel Electronics
00:0B:E7	ComfluxTec             # COMFLUX TECHNOLOGY INC.
00:0B:E8	Aoip
00:0B:E9	Actel                  # Actel Corporation
00:0B:EA	ZultysTech             # Zultys Technologies
00:0B:EB	Systegra               # Systegra AG
00:0B:EC	NipponElec             # NIPPON ELECTRIC INSTRUMENT, INC.
00:0B:ED	Elm                    # ELM Inc.
00:0B:EE	Jet                    # inc.jet, Incorporated
00:0B:EF	Code                   # Code Corporation
00:0B:F0	MotexProdu             # MoTEX Products Co., Ltd.
00:0B:F1	LapLaserAp             # LAP Laser Applikations
00:0B:F2	Chih-KanTe             # Chih-Kan Technology Co., Ltd.
00:0B:F3	Bae                    # BAE SYSTEMS
00:0B:F4	Private
00:0B:F5	ShanghaiSi             # Shanghai Sibo Telecom Technology Co.,Ltd
00:0B:F6	Nitgen                 # Nitgen Co., Ltd
00:0B:F7	Nidek                  # NIDEK CO.,LTD
00:0B:F8	Infinera
00:0B:F9	GemstoneCo             # Gemstone communications, Inc.
00:0B:FA	ExemysSrl              # EXEMYS SRL
00:0B:FB	D-NetInter             # D-NET International Corporation
00:0B:FC	Cisco                  # Cisco Systems
00:0B:FD	Cisco                  # Cisco Systems
00:0B:FE	CastelBroa             # CASTEL Broadband Limited
00:0B:FF	BerkeleyCa             # Berkeley Camera Engineering
00:0C:00	BebIndustr             # BEB Industrie-Elektronik AG
00:0C:01	Abatron                # Abatron AG
00:0C:02	AbbOy                  # ABB Oy
00:0C:03	HdmiLicens             # HDMI Licensing, LLC
00:0C:04	Tecnova
00:0C:05	RpaReserch             # RPA Reserch Co., Ltd.
00:0C:06	NixvuePte              # Nixvue Systems  Pte Ltd
00:0C:07	Iftest                 # Iftest AG
00:0C:08	HumexTechn             # HUMEX Technologies Corp.
00:0C:09	HitachiIe              # Hitachi IE Systems Co., Ltd
00:0C:0A	GuangdongP             # Guangdong Province Electronic Technology Research Institute
00:0C:0B	BroadbusTe             # Broadbus Technologies
00:0C:0C	ApproTechn             # APPRO TECHNOLOGY INC.
00:0C:0D	Communicat             # Communications & Power Industries / Satcom Division
00:0C:0E	Xtremespec             # XtremeSpectrum, Inc.
00:0C:0F	Techno-One             # Techno-One Co., Ltd
00:0C:10	Pni                    # PNI Corporation
00:0C:11	NipponDemp             # NIPPON DEMPA CO.,LTD.
00:0C:12	Micro-Optr             # Micro-Optronic-Messtechnik GmbH
00:0C:13	Mediaq
00:0C:14	Diagnostic             # Diagnostic Instruments, Inc.
00:0C:15	Cyberpower             # CyberPower Systems, Inc.
00:0C:16	ConcordeMi             # Concorde Microsystems Inc.
00:0C:17	AjaVideo               # AJA Video Systems Inc
00:0C:18	ZenisuKeis             # Zenisu Keisoku Inc.
00:0C:19	TelioCommu             # Telio Communications GmbH
00:0C:1A	QuestTechn             # Quest Technical Solutions Inc.
00:0C:1B	Oracom                 # ORACOM Co, Ltd.
00:0C:1C	Microweb               # MicroWeb Co., Ltd.
00:0C:1D	MettlerFuc             # Mettler & Fuchs AG
00:0C:1E	GlobalCach             # Global Cache
00:0C:1F	Glimmergla             # Glimmerglass Networks
00:0C:20	FiWin                  # Fi WIn, Inc.
00:0C:21	FacultyOfS             # Faculty of Science and Technology, Keio University
00:0C:22	DoubleDEle             # Double D Electronics Ltd
00:0C:23	BeijingLan             # Beijing Lanchuan Tech. Co., Ltd.
00:0C:24	Anator
00:0C:25	AlliedTele             # Allied Telesyn Networks
00:0C:26	WeintekLab             # Weintek Labs. Inc.
00:0C:27	Sammy                  # Sammy Corporation
00:0C:28	Rifatron
00:0C:29	Vmware                 # VMware, Inc.
00:0C:2A	OcttelComm             # OCTTEL Communication Co., Ltd.
00:0C:2B	EliasTechn             # ELIAS Technology, Inc.
00:0C:2C	Enwiser                # Enwiser Inc.
00:0C:2D	FullwaveTe             # FullWave Technology Co., Ltd.
00:0C:2E	OpenetInfo             # Openet information technology(shenzhen) Co., Ltd.
00:0C:2F	Seorimtech             # SeorimTechnology Co.,Ltd.
00:0C:30	Cisco
00:0C:31	Cisco
00:0C:32	AvionicDes             # Avionic Design Development GmbH
00:0C:33	CompucaseE             # Compucase Enterprise Co. Ltd.
00:0C:34	Vixen                  # Vixen Co., Ltd.
00:0C:35	KavoDental             # KaVo Dental GmbH & Co. KG
00:0C:36	SharpTakay             # SHARP TAKAYA ELECTRONICS INDUSTRY CO.,LTD.
00:0C:37	Geomation              # Geomation, Inc.
00:0C:38	Telcobridg             # TelcoBridges Inc.
00:0C:39	SentinelWi             # Sentinel Wireless Inc.
00:0C:3A	Oxance
00:0C:3B	OrionElect             # Orion Electric Co., Ltd.
00:0C:3C	Mediachoru             # MediaChorus, Inc.
00:0C:3D	Glsystech              # Glsystech Co., Ltd.
00:0C:3E	CrestAudio             # Crest Audio
00:0C:3F	CogentDefe             # Cogent Defence & Security Networks,
00:0C:40	AltechCont             # Altech Controls
00:0C:41	LinksysGro             # The Linksys Group, Inc.
00:0C:42	Routerboar             # Routerboard.com
00:0C:43	RalinkTech             # Ralink Technology, Corp.
00:0C:44	AutomatedI             # Automated Interfaces, Inc.
00:0C:45	AnimationT             # Animation Technologies Inc.
00:0C:46	AlliedTele             # Allied Telesyn Inc.
00:0C:47	SkTeletech             # SK Teletech(R&D Planning Team)
00:0C:48	Qostek                 # QoStek Corporation
00:0C:49	DangaardTe             # Dangaard Telecom RTC Division A/S
00:0C:4A	CygnusMicr             # Cygnus Microsystems Private Limited
00:0C:4B	CheopsElek             # Cheops Elektronik
00:0C:4C	ArcorAg&Co             # Arcor AG&Co.
00:0C:4D	AcraContro             # ACRA CONTROL
00:0C:4E	WinbestTec             # Winbest Technology CO,LT
00:0C:4F	UdtechJapa             # UDTech Japan Corporation
00:0C:50	SeagateTec             # Seagate Technology
00:0C:51	Scientific             # Scientific Technologies Inc.
00:0C:52	Roll                   # Roll Systems Inc.
00:0C:53	Private
00:0C:54	PedestalNe             # Pedestal Networks, Inc
00:0C:55	MicrolinkC             # Microlink Communications Inc.
00:0C:56	MegatelCom             # Megatel Computer (1986) Corp.
00:0C:57	MackieEngi             # MACKIE Engineering Services Belgium BVBA
00:0C:58	M&S                    # M&S Systems
00:0C:59	IndymeElec             # Indyme Electronics, Inc.
00:0C:5A	IbsmmIndus             # IBSmm Industrieelektronik Multimedia
00:0C:5B	HanwangTec             # HANWANG TECHNOLOGY CO.,LTD
00:0C:5C	GtnBV                  # GTN Systems B.V.
00:0C:5D	ChicTechno             # CHIC TECHNOLOGY (CHINA) CORP.
00:0C:5E	CalypsoMed             # Calypso Medical
00:0C:5F	Avtec                  # Avtec, Inc.
00:0C:60	Acm                    # ACM Systems
00:0C:61	AcTechDbaA             # AC Tech corporation DBA Advanced Digital
00:0C:62	AbbAutomat             # ABB Automation Technology Products AB, Control
00:0C:63	ZenithElec             # Zenith Electronics Corporation
00:0C:64	X2MsaGroup             # X2 MSA Group
00:0C:65	SuninTelec             # Sunin Telecom
00:0C:66	ProntoNetw             # Pronto Networks Inc
00:0C:67	OyoElectri             # OYO ELECTRIC CO.,LTD
00:0C:68	OasisSemic             # Oasis Semiconductor, Inc.
00:0C:69	NationalRa             # National Radio Astronomy Observatory
00:0C:6A	Mbari
00:0C:6B	KurzIndust             # Kurz Industrie-Elektronik GmbH
00:0C:6C	ElgatoLlc              # Elgato Systems LLC
00:0C:6D	BocEdwards             # BOC Edwards
00:0C:6E	AsustekCom             # ASUSTEK COMPUTER INC.
00:0C:6F	AmtekSyste             # Amtek system co.,LTD.
00:0C:70	Acc                    # ACC GmbH
00:0C:71	Wybron                 # Wybron, Inc
00:0C:72	TempearlIn             # Tempearl Industrial Co., Ltd.
00:0C:73	TelsonElec             # TELSON ELECTRONICS CO., LTD
00:0C:74	Rivertec               # RIVERTEC CORPORATION
00:0C:75	OrientalIn             # Oriental integrated electronics. LTD
00:0C:76	Micro-Star             # MICRO-STAR INTERNATIONAL CO., LTD.
00:0C:77	LifeRacing             # Life Racing Ltd
00:0C:78	In-TechEle             # In-Tech Electronics Limited
00:0C:79	ExtelCommu             # Extel Communications P/L
00:0C:7A	DatariusTe             # DaTARIUS Technologies GmbH
00:0C:7B	AlphaProje             # ALPHA PROJECT Co.,Ltd.
00:0C:7C	InternetIn             # Internet Information Image Inc.
00:0C:7D	TeikokuEle             # TEIKOKU ELECTRIC MFG. CO., LTD
00:0C:7E	Tellium                # Tellium Incorporated
00:0C:7F	Synertroni             # synertronixx GmbH
00:0C:80	Opelcomm               # Opelcomm Inc.
00:0C:81	NulecIndus             # Nulec Industries Pty Ltd
00:0C:82	NetworkTec             # NETWORK TECHNOLOGIES INC
00:0C:83	LogicalSol             # Logical Solutions
00:0C:84	Eazix                  # Eazix, Inc.
00:0C:85	Cisco                  # Cisco Systems
00:0C:86	Cisco                  # Cisco Systems
00:0C:87	Ati
00:0C:88	ApacheMicr             # Apache Micro Peripherals, Inc.
00:0C:89	AcElectric             # AC Electric Vehicles, Ltd.
00:0C:8A	Bose                   # Bose Corporation
00:0C:8B	ConnectTec             # Connect Tech Inc
00:0C:8C	Kodicom                # KODICOM CO.,LTD.
00:0C:8D	MatrixVisi             # MATRIX VISION GmbH
00:0C:8E	MentorEngi             # Mentor Engineering Inc
00:0C:8F	NergalSRL              # Nergal s.r.l.
00:0C:90	Octasic                # Octasic Inc.
00:0C:91	RiverheadN             # Riverhead Networks Inc.
00:0C:92	Wolfvision             # WolfVision Gmbh
00:0C:93	Xeline                 # Xeline Co., Ltd.
00:0C:94	UnitedElec             # United Electronic Industries, Inc.
00:0C:95	Primenet
00:0C:96	Oqo                    # OQO, Inc.
00:0C:97	NvAdbTtvTe             # NV ADB TTV Technologies SA
00:0C:98	LetekCommu             # LETEK Communications Inc.
00:0C:99	HitelLink              # HITEL LINK Co.,Ltd
00:0C:9A	HitechElec             # Hitech Electronics Corp.
00:0C:9B	EeSolution             # EE Solutions, Inc
00:0C:9C	ChonghoInf             # Chongho information & communications
00:0C:9D	AirwalkCom             # AirWalk Communications, Inc.
00:0C:9E	Memorylink             # MemoryLink Corp.
00:0C:9F	Nke                    # NKE Corporation
00:0C:A0	StorcaseTe             # StorCase Technology, Inc.
00:0C:A1	Sigmacom               # SIGMACOM Co., LTD.
00:0C:A2	ScopusNetw             # Scopus Network Technologies Ltd
00:0C:A3	RanchoTech             # Rancho Technology, Inc.
00:0C:A4	PrompttecP             # Prompttec Product Management GmbH
00:0C:A5	NamanNz                # Naman NZ LTd
00:0C:A6	Mintera                # Mintera Corporation
00:0C:A7	MetroSuzho             # Metro (Suzhou) Technologies Co., Ltd.
00:0C:A8	GarudaNetw             # Garuda Networks Corporation
00:0C:A9	Ebtron                 # Ebtron Inc.
00:0C:AA	CubicTrans             # Cubic Transportation Systems Inc
00:0C:AB	CommendInt             # COMMEND International
00:0C:AC	CitizenWat             # Citizen Watch Co., Ltd.
00:0C:AD	BtuInterna             # BTU International
00:0C:AE	AilocomOy              # Ailocom Oy
00:0C:AF	TriTerm                # TRI TERM CO.,LTD.
00:0C:B0	StarSemico             # Star Semiconductor Corporation
00:0C:B1	SallandEng             # Salland Engineering (Europe) BV
00:0C:B2	Safei                  # safei Co., Ltd.
00:0C:B3	Round                  # ROUND Co.,Ltd.
00:0C:B4	AutocellLa             # AutoCell Laboratories, Inc.
00:0C:B5	PremierTec             # Premier Technolgies, Inc
00:0C:B6	NanjingSeu             # NANJING SEU MOBILE & INTERNET TECHNOLOGY CO.,LTD
00:0C:B7	NanjingHua             # Nanjing Huazhuo Electronics Co., Ltd.
00:0C:B8	Medion                 # MEDION AG
00:0C:B9	Lea
00:0C:BA	Jamex
00:0C:BB	Iskraemeco
00:0C:BC	Iscutum
00:0C:BD	InterfaceM             # Interface Masters, Inc
00:0C:BE	Private
00:0C:BF	HolyStoneE             # Holy Stone Ent. Co., Ltd.
00:0C:C0	GeneraOy               # Genera Oy
00:0C:C1	CooperIndu             # Cooper Industries Inc.
00:0C:C2	Private
00:0C:C3	Bewan                  # BeWAN systems
00:0C:C4	Tiptel                 # Tiptel AG
00:0C:C5	Nextlink               # Nextlink Co., Ltd.
00:0C:C6	Ka-RoElect             # Ka-Ro electronics GmbH
00:0C:C7	Intelligen             # Intelligent Computer Solutions Inc.
00:0C:C8	XytronixRe             # Xytronix Research & Design, Inc.
00:0C:C9	IlwooDataT             # ILWOO DATA & TECHNOLOGY CO.,LTD
00:0C:CA	HitachiGlo             # Hitachi Global Storage Technologies
00:0C:CB	DesignComb             # Design Combus Ltd
00:0C:CC	Aeroscout              # Aeroscout Ltd.
00:0C:CD	Iec-Tc57               # IEC - TC57
00:0C:CE	Cisco                  # Cisco Systems
00:0C:CF	Cisco                  # Cisco Systems
00:0C:D0	Symetrix
00:0C:D1	SfomTechno             # SFOM Technology Corp.
00:0C:D2	SchaffnerE             # Schaffner EMV AG
00:0C:D3	PrettlElek             # Prettl Elektronik Radeberg GmbH
00:0C:D4	PositronPu             # Positron Public Safety Systems inc.
00:0C:D5	Passave                # Passave Inc.
00:0C:D6	PartnerTec             # PARTNER TECH
00:0C:D7	Nallatech              # Nallatech Ltd
00:0C:D8	MKJuchheim             # M. K. Juchheim GmbH & Co
00:0C:D9	Itcare                 # Itcare Co., Ltd
00:0C:DA	Freehand               # FreeHand Systems, Inc.
00:0C:DB	FoundryNet             # Foundry Networks
00:0C:DC	BecsTechno             # BECS Technology, Inc
00:0C:DD	AosTechnol             # AOS Technologies AG
00:0C:DE	AbbStotz-K             # ABB STOTZ-KONTAKT GmbH
00:0C:DF	PulnixAmer             # PULNiX America, Inc
00:0C:E0	TrekDiagno             # Trek Diagnostics Inc.
00:0C:E1	OpenGroup              # The Open Group
00:0C:E2	Rolls-Royc             # Rolls-Royce
00:0C:E3	OptionInte             # Option International N.V.
00:0C:E4	NeurocomIn             # NeuroCom International, Inc.
00:0C:E5	MotorolaBc             # Motorola BCS
00:0C:E6	MeruNetwor             # Meru Networks Inc
00:0C:E7	Mediatek               # MediaTek Inc.
00:0C:E8	GuangzhouA             # GuangZhou AnJuBao Co., Ltd
00:0C:E9	BloombergL             # BLOOMBERG L.P.
00:0C:EA	AphonaKomm             # aphona Kommunikationssysteme
00:0C:EB	CnmpNetwor             # CNMP Networks, Inc.
00:0C:EC	Spectracom             # Spectracom Corp.
00:0C:ED	RealDigita             # Real Digital Media
00:0C:EE	Jp-Embedde             # jp-embedded
00:0C:EF	OpenNetwor             # Open Networks Engineering Ltd
00:0C:F0	MN                     # M & N GmbH
00:0C:F1	Intel                  # Intel Corporation
00:0C:F2	GamesaE�Li             # GAMESA E�LICA
00:0C:F3	CallImageS             # CALL IMAGE SA
00:0C:F4	AkatsukiEl             # AKATSUKI ELECTRIC MFG.CO.,LTD.
00:0C:F5	Infoexpres             # InfoExpress
00:0C:F6	SitecomEur             # Sitecom Europe BV
00:0C:F7	NortelNetw             # Nortel Networks
00:0C:F8	NortelNetw             # Nortel Networks
00:0C:F9	IttFlygt               # ITT Flygt AB
00:0C:FA	Digital                # Digital Systems Corp
00:0C:FB	KoreaNetwo             # Korea Network Systems
00:0C:FC	S2ioTechno             # S2io Technologies Corp
00:0C:FD	Private
00:0C:FE	GrandElect             # Grand Electronic Co., Ltd
00:0C:FF	Mro-Tek                # MRO-TEK LIMITED
00:0D:00	SeawayNetw             # Seaway Networks Inc.
00:0D:01	P&EMicroco             # P&E Microcomputer Systems, Inc.
00:0D:02	NecAccessT             # NEC Access Technica,Ltd
00:0D:03	Matrics                # Matrics, Inc.
00:0D:04	FoxboroEck             # Foxboro Eckardt Development GmbH
00:0D:05	CybernetMa             # cybernet manufacturing inc.
00:0D:06	Compulogic             # Compulogic Limited
00:0D:07	CalrecAudi             # Calrec Audio Ltd
00:0D:08	Abovecable             # AboveCable, Inc.
00:0D:09	YuehuaZhuh             # Yuehua(Zhuhai) Electronic CO. LTD
00:0D:0A	Projection             # Projectiondesign as
00:0D:0B	Buffalo                # Buffalo Inc.
00:0D:0C	MdiSecurit             # MDI Security Systems
00:0D:0D	Itsupporte             # ITSupported, LLC
00:0D:0E	Inqnet                 # Inqnet Systems, Inc.
00:0D:0F	Finlux                 # Finlux Ltd
00:0D:10	Embedtroni             # Embedtronics Oy
00:0D:11	Dentsply-G             # DENTSPLY - Gendex
00:0D:12	Axell                  # AXELL Corporation
00:0D:13	WilhelmRut             # Wilhelm Rutenbeck GmbH&Co.
00:0D:14	VtechInnov             # Vtech Innovation LP dba Advanced American Telephones
00:0D:15	VoipacSRO              # Voipac s.r.o.
00:0D:16	UhsPty                 # UHS Systems Pty Ltd
00:0D:17	TurboNetwo             # Turbo Networks Co.Ltd
00:0D:18	SunitecEnt             # Sunitec Enterprise Co., Ltd.
00:0D:19	RobeShowLi             # ROBE Show lighting
00:0D:1A	MustekSyst             # Mustek System Inc.
00:0D:1B	KyotoElect             # Kyoto Electronics Manufacturing Co., Ltd.
00:0D:1C	I2eTelecom             # I2E TELECOM
00:0D:1D	High-TekHa             # HIGH-TEK HARNESS ENT. CO., LTD.
00:0D:1E	ControlTec             # Control Techniques
00:0D:1F	AvDigital              # AV Digital
00:0D:20	Asahikasei             # ASAHIKASEI TECHNOSYSTEM CO.,LTD.
00:0D:21	Wiscore                # WISCORE Inc.
00:0D:22	Unitronics
00:0D:23	SmartSolut             # Smart Solution, Inc
00:0D:24	SentecE&E              # SENTEC E&E CO., LTD.
00:0D:25	Sanden                 # SANDEN CORPORATION
00:0D:26	Primagraph             # Primagraphics Limited
00:0D:27	MicroplexP             # MICROPLEX Printware AG
00:0D:28	Cisco
00:0D:29	Cisco
00:0D:2A	ScanmaticA             # Scanmatic AS
00:0D:2B	RacalInstr             # Racal Instruments
00:0D:2C	PatapscoDe             # Patapsco Designs Ltd
00:0D:2D	NctDeutsch             # NCT Deutschland GmbH
00:0D:2E	Matsushita             # Matsushita Avionics Systems Corporation
00:0D:2F	AinCommTec             # AIN Comm.Tech.Co., LTD
00:0D:30	IcefyreSem             # IceFyre Semiconductor
00:0D:31	Compellent             # Compellent Technologies, Inc.
00:0D:32	Dispenseso             # DispenseSource, Inc.
00:0D:33	Prediwave              # Prediwave Corp.
00:0D:34	ShellInter             # Shell International Exploration and Production, Inc.
00:0D:35	PacInterna             # PAC International Ltd
00:0D:36	WuHanRouto             # Wu Han Routon Electronic Co., Ltd
00:0D:37	Wiplug
00:0D:38	Nissin                 # NISSIN INC.
00:0D:39	NetworkEle             # Network Electronics
00:0D:3A	Microsoft              # Microsoft Corp.
00:0D:3B	Microelect             # Microelectronics Technology Inc.
00:0D:3C	ITechDynam             # i.Tech Dynamic Ltd
00:0D:3D	Hammerhead             # Hammerhead Systems, Inc.
00:0D:3E	ApluxCommu             # APLUX Communications Ltd.
00:0D:3F	VxiTechnol             # VXI Technology
00:0D:40	VerintLoro             # Verint Loronix Video Solutions
00:0D:41	SiemensIcm             # Siemens AG ICM MP UC RD IT KLF1
00:0D:42	NewbestDev             # Newbest Development Limited
00:0D:43	DrsTactica             # DRS Tactical Systems Inc.
00:0D:44	Private
00:0D:45	TottoriSan             # Tottori SANYO Electric Co., Ltd.
00:0D:46	SsdDrives              # SSD Drives, Inc.
00:0D:47	Collex
00:0D:48	AewinTechn             # AEWIN Technologies Co., Ltd.
00:0D:49	TritonOfDe             # Triton Systems of Delaware, Inc.
00:0D:4A	SteagEta-O             # Steag ETA-Optik
00:0D:4B	RokuLlc                # Roku, LLC
00:0D:4C	OutlineEle             # Outline Electronics Ltd.
00:0D:4D	Ninelanes
00:0D:4E	Ndr                    # NDR Co.,LTD.
00:0D:4F	Kenwood                # Kenwood Corporation
00:0D:50	GalazarNet             # Galazar Networks
00:0D:51	Divr                   # DIVR Systems, Inc.
00:0D:52	ComartSyst             # Comart system
00:0D:53	Beijing5wC             # Beijing 5w Communication Corp.
00:0D:54	3comEurope             # 3Com Europe Ltd
00:0D:55	SanycomTec             # SANYCOM Technology Co.,Ltd
00:0D:56	DellPcbaTe             # Dell PCBA Test
00:0D:57	FujitsuI-N             # Fujitsu I-Network Systems Limited.
00:0D:58	Private
00:0D:59	Amity                  # Amity Systems, Inc.
00:0D:5A	TiesseSpa              # Tiesse SpA
00:0D:5B	SmartEmpir             # Smart Empire Investments Limited
00:0D:5C	RobertBosc             # Robert Bosch GmbH, VT-ATMO
00:0D:5D	RaritanCom             # Raritan Computer, Inc
00:0D:5E	NecCustomt             # NEC CustomTechnica, Ltd.
00:0D:5F	Minds                  # Minds Inc
00:0D:60	Ibm                    # IBM Corporation
00:0D:61	Giga-ByteT             # Giga-Byte Technology Co., Ltd.
00:0D:62	FunkwerkDa             # Funkwerk Dabendorf GmbH
00:0D:63	DentInstru             # DENT Instruments, Inc.
00:0D:64	ComagHande             # COMAG Handels AG
00:0D:65	Cisco                  # Cisco Systems
00:0D:66	Cisco                  # Cisco Systems
00:0D:67	BelairNetw             # BelAir Networks Inc.
00:0D:68	Vinci                  # Vinci Systems, Inc.
00:0D:69	Tmt&D                  # TMT&D Corporation
00:0D:6A	RedwoodTec             # Redwood Technologies LTD
00:0D:6B	Mita-Tekni             # Mita-Teknik A/S
00:0D:6C	M-Audio
00:0D:6D	K-TechDevi             # K-Tech Devices Corp.
00:0D:6E	K-PatentsO             # K-Patents Oy
00:0D:6F	Ember                  # Ember Corporation
00:0D:70	Datamax                # Datamax Corporation
00:0D:71	Boca                   # boca systems
00:0D:72	2wire                  # 2Wire, Inc
00:0D:73	TechnicalS             # Technical Support, Inc.
00:0D:74	SandNetwor             # Sand Network Systems, Inc.
00:0D:75	KobianPte-             # Kobian Pte Ltd - Taiwan Branch
00:0D:76	HokutoDens             # Hokuto Denshi Co,. Ltd.
00:0D:77	Falconstor             # FalconStor Software
00:0D:78	Engineerin             # Engineering & Security
00:0D:79	DynamicSol             # Dynamic Solutions Co,.Ltd.
00:0D:7A	DigattoAsi             # DiGATTO Asia Pacific Pte Ltd
00:0D:7B	ConsensysC             # Consensys Computers Inc.
00:0D:7C	Codian                 # Codian Ltd
00:0D:7D	Afco                   # Afco Systems
00:0D:7E	AxiowaveNe             # Axiowave Networks, Inc.
00:0D:7F	MidasCommu             # MIDAS  COMMUNICATION TECHNOLOGIES PTE LTD ( Foreign Branch)
00:0D:80	OnlineDeve             # Online Development Inc
00:0D:81	Pepperl+Fu             # Pepperl+Fuchs GmbH
00:0D:82	PhsSrl                 # PHS srl
00:0D:83	Sanmina-Sc             # Sanmina-SCI Hungary  Ltd.
00:0D:84	Makus                  # Makus Inc.
00:0D:85	Tapwave                # Tapwave, Inc.
00:0D:86	Huber+Suhn             # Huber + Suhner AG
00:0D:87	Elitegroup             # Elitegroup Computer System Co. (ECS)
00:0D:88	D-Link                 # D-Link Corporation
00:0D:89	BilsTechno             # Bils Technology Inc
00:0D:8A	WinnersEle             # Winners Electronics Co., Ltd.
00:0D:8B	T&D                    # T&D Corporation
00:0D:8C	ShanghaiWe             # Shanghai Wedone Digital Ltd. CO.
00:0D:8D	ProlinxCom             # ProLinx Communication Gateways, Inc.
00:0D:8E	KodenElect             # Koden Electronics Co., Ltd.
00:0D:8F	KingTsushi             # King Tsushin Kogyo Co., LTD.
00:0D:90	FactumElec             # Factum Electronics AB
00:0D:91	EclipseHqE             # Eclipse (HQ Espana) S.L.
00:0D:92	ArimaCommu             # Arima Communication Corporation
00:0D:93	AppleCompu             # Apple Computer
00:0D:94	AfarCommun             # AFAR Communications,Inc
00:0D:95	Opti-Cell              # Opti-cell, Inc.
00:0D:96	VteraTechn             # Vtera Technology Inc.
00:0D:97	TroposNetw             # Tropos Networks, Inc.
00:0D:98	SWACSchmit             # S.W.A.C. Schmitt-Walter Automation Consult GmbH
00:0D:99	OrbitalSci             # Orbital Sciences Corp.; Launch Systems Group
00:0D:9A	Infotec                # INFOTEC LTD
00:0D:9B	HeraeusEle             # Heraeus Electro-Nite International N.V.
00:0D:9C	Elan                   # Elan GmbH & Co KG
00:0D:9D	HewlettPac             # Hewlett Packard
00:0D:9E	TokudenOhi             # TOKUDEN OHIZUMI SEISAKUSYO Co.,Ltd.
00:0D:9F	RfMicroDev             # RF Micro Devices
00:0D:A0	NedapNV                # NEDAP N.V.
00:0D:A1	MiraeIts               # MIRAE ITS Co.,LTD.
00:0D:A2	InfrantTec             # Infrant Technologies, Inc.
00:0D:A3	EmergingTe             # Emerging Technologies Limited
00:0D:A4	DoschAmand             # DOSCH & AMAND SYSTEMS AG
00:0D:A5	Fabric7                # Fabric7 Systems, Inc
00:0D:A6	UniversalS             # Universal Switching Corporation
00:0D:A7	Private
00:0D:A8	Teletronic             # Teletronics Technology Corporation
00:0D:A9	TEAMSL                 # T.E.A.M. S.L.
00:0D:AA	SATehnolog             # S.A.Tehnology co.,Ltd.
00:0D:AB	ParkerHann             # Parker Hannifin GmbH Electromechanical Division Europe
00:0D:AC	JapanCbm               # Japan CBM Corporation
00:0D:AD	Dataprobe              # Dataprobe Inc
00:0D:AE	SamsungHea             # SAMSUNG HEAVY INDUSTRIES CO., LTD.
00:0D:AF	PlexusUk               # Plexus Corp (UK) Ltd
00:0D:B0	Olym-Tech              # Olym-tech Co.,Ltd.
00:0D:B1	JapanNetwo             # Japan Network Service Co., Ltd.
00:0D:B2	Ammasso                # Ammasso, Inc.
00:0D:B3	SdoCommuni             # SDO Communication Corperation
00:0D:B4	Netasq
00:0D:B5	GlobalsatT             # GLOBALSAT TECHNOLOGY CORPORATION
00:0D:B6	Teknovus               # Teknovus, Inc.
00:0D:B7	SankoElect             # SANKO ELECTRIC CO,.LTD
00:0D:B8	Schiller               # SCHILLER AG
00:0D:B9	PcEngines              # PC Engines GmbH
00:0D:BA	Oc�Documen             # Oc� Document Technologies GmbH
00:0D:BB	NipponDent             # Nippon Dentsu Co.,Ltd.
00:0D:BC	Cisco                  # Cisco Systems
00:0D:BD	Cisco                  # Cisco Systems
00:0D:BE	BelFuseEur             # Bel Fuse Europe Ltd.,UK
00:0D:BF	TektoneSou             # TekTone Sound & Signal Mfg., Inc.
00:0D:C0	SpagatAs               # Spagat AS
00:0D:C1	Safeweb                # SafeWeb Inc
00:0D:C2	Private
00:0D:C3	FirstCommu             # First Communication, Inc.
00:0D:C4	Emcore                 # Emcore Corporation
00:0D:C5	EchostarIn             # EchoStar International Corporation
00:0D:C6	DigiroseTe             # DigiRose Technology Co., Ltd.
00:0D:C7	CosmicEngi             # COSMIC ENGINEERING INC.
00:0D:C8	Airmagnet              # AirMagnet, Inc
00:0D:C9	ThalesElek             # THALES Elektronik Systeme GmbH
00:0D:CA	TaitElectr             # Tait Electronics
00:0D:CB	Petcomkore             # Petcomkorea Co., Ltd.
00:0D:CC	Neosmart               # NEOSMART Corp.
00:0D:CD	GroupeTxco             # GROUPE TXCOM
00:0D:CE	DynavacTec             # Dynavac Technology Pte Ltd
00:0D:CF	Cidra                  # Cidra Corp.
00:0D:D0	TetratecIn             # TetraTec Instruments GmbH
00:0D:D1	Stryker                # Stryker Corporation
00:0D:D2	SimradOptr             # Simrad Optronics ASA
00:0D:D3	SamwooTele             # SAMWOO Telecommunication Co.,Ltd.
00:0D:D4	Revivio                # Revivio Inc.
00:0D:D5	ORiteTechn             # O'RITE TECHNOLOGY CO.,LTD
00:0D:D6	Iti                    # ITI    LTD
00:0D:D7	Bright
00:0D:D8	Bbn
00:0D:D9	AntonPaar              # Anton Paar GmbH
00:0D:DA	AlliedTele             # ALLIED TELESIS K.K.
00:0D:DB	AirwaveTec             # AIRWAVE TECHNOLOGIES INC.
00:0D:DC	Vac
00:0D:DD	Prof�LoTel             # PROF�LO TELRA ELEKTRON�K SANAY� VE T�CARET A.�.
00:0D:DE	Joyteck                # Joyteck Co., Ltd.
00:0D:DF	JapanImage             # Japan Image & Network Inc.
00:0D:E0	Icpdas                 # ICPDAS Co.,LTD
00:0D:E1	ControlPro             # Control Products, Inc.
00:0D:E2	CmzSistemi             # CMZ Sistemi Elettronici
00:0D:E3	AtSweden               # AT Sweden AB
00:0D:E4	Diginics               # DIGINICS, Inc.
00:0D:E5	SamsungTha             # Samsung Thales
00:0D:E6	YoungboEng             # YOUNGBO ENGINEERING CO.,LTD
00:0D:E7	Snap-OnOem             # Snap-on OEM Group
00:0D:E8	NasacoElec             # Nasaco Electronics Pte. Ltd
00:0D:E9	NapatechAp             # Napatech Aps
00:0D:EA	KingtelTel             # Kingtel Telecommunication Corp.
00:0D:EB	Compxs                 # CompXs Limited
00:0D:EC	Cisco                  # Cisco Systems
00:0D:ED	Cisco                  # Cisco Systems
00:0D:EE	AndrewRfPo             # Andrew RF Power Amplifier Group
00:0D:EF	SocCoopBil             # Soc. Coop. Bilanciai
00:0D:F0	QcomTechno             # QCOM TECHNOLOGY INC.
00:0D:F1	Ionix                  # IONIX INC.
00:0D:F2	Private
00:0D:F3	AsmaxSolut             # Asmax Solutions
00:0D:F4	Watertek               # Watertek Co.
00:0D:F5	Teletronic             # Teletronics International Inc.
00:0D:F6	Technology             # Technology Thesaurus Corp.
00:0D:F7	SpaceDynam             # Space Dynamics Lab
00:0D:F8	OrgaKarten             # ORGA Kartensysteme GmbH
00:0D:F9	Nds                    # NDS Limited
00:0D:FA	MicroContr             # Micro Control Systems Ltd.
00:0D:FB	Komax                  # Komax AG
00:0D:FC	ItforResar             # ITFOR Inc. resarch and development
00:0D:FD	HugesHi-Te             # Huges Hi-Tech Inc.,
00:0D:FE	HauppaugeC             # Hauppauge Computer Works, Inc.
00:0D:FF	ChenmingMo             # CHENMING MOLD INDUSTRY CORP.
00:0E:00	Atrie
00:0E:01	AsipTechno             # ASIP Technologies Inc.
00:0E:02	AdvantechA             # Advantech AMT Inc.
00:0E:03	AarohiComm             # Aarohi Communications, Inc.
00:0E:04	Cma/Microd             # CMA/Microdialysis AB
00:0E:05	WirelessMa             # WIRELESS MATRIX CORP.
00:0E:06	TeamSimoco             # Team Simoco Ltd
00:0E:07	SonyEricss             # Sony Ericsson Mobile Communications AB
00:0E:08	SipuraTech             # Sipura Technology, Inc.
00:0E:09	ShenzhenCo             # Shenzhen Coship Software Co.,LTD.
00:0E:0A	SakumaDesi             # SAKUMA DESIGN OFFICE
00:0E:0B	NetacTechn             # Netac Technology Co., Ltd.
00:0E:0C	Intel                  # Intel Corporation
00:0E:0D	HeschSchr�             # HESCH Schr�der GmbH
00:0E:0E	EsaElettro             # ESA elettronica S.P.A.
00:0E:0F	Ermme
00:0E:10	Private
00:0E:11	BdtB�Ro-Un             # BDT B�ro- und Datentechnik GmbH & Co. KG
00:0E:12	AdaptiveMi             # Adaptive Micro Systems Inc.
00:0E:13	Accu-Sort              # Accu-Sort Systems inc.
00:0E:14	VisionaryS             # Visionary Solutions, Inc.
00:0E:15	Tadlys                 # Tadlys LTD
00:0E:16	Southwing
00:0E:17	Private
00:0E:18	MyaTechnol             # MyA Technology
00:0E:19	LogicacmgP             # LogicaCMG Pty Ltd
00:0E:1A	JpsCommuni             # JPS Communications
00:0E:1B	Iav                    # IAV GmbH
00:0E:1C	Hach                   # Hach Company
00:0E:1D	ArionTechn             # ARION Technology Inc.
00:0E:1E	Private
00:0E:1F	TclNetwork             # TCL Networks Equipment Co., Ltd.
00:0E:20	Palmsource             # PalmSource, Inc.
00:0E:21	MtuFriedri             # MTU Friedrichshafen GmbH
00:0E:22	Private
00:0E:23	Incipient              # Incipient, Inc.
00:0E:24	HuwellTech             # Huwell Technology Inc.
00:0E:25	HannaeTech             # Hannae Technology Co., Ltd
00:0E:26	GincomTech             # Gincom Technology Corp.
00:0E:27	CrereNetwo             # Crere Networks, Inc.
00:0E:28	DynamicRat             # Dynamic Ratings P/L
00:0E:29	ShesterCom             # Shester Communications Inc
00:0E:2A	Private
00:0E:2B	SafariTech             # Safari Technologies
00:0E:2C	Netcodec               # Netcodec co.
00:0E:2D	HyundaiDig             # Hyundai Digital Technology Co.,Ltd.
00:0E:2E	EdimaxTech             # Edimax Technology Co., Ltd.
00:0E:2F	Disetronic             # Disetronic Medical Systems AG
00:0E:30	AerasNetwo             # AERAS Networks, Inc.
00:0E:31	OlympusBio             # Olympus BioSystems GmbH
00:0E:32	KontronMed             # Kontron Medical
00:0E:33	ShukoElect             # Shuko Electronics Co.,Ltd
00:0E:34	NexgenCity             # NexGen City, LP
00:0E:35	Intel                  # Intel Corp
00:0E:36	Heinesys               # HEINESYS, Inc.
00:0E:37	HarmsWende             # Harms & Wende GmbH & Co.KG
00:0E:38	Cisco                  # Cisco Systems
00:0E:39	Cisco                  # Cisco Systems
00:0E:3A	CirrusLogi             # Cirrus Logic
00:0E:3B	HawkingTec             # Hawking Technologies, Inc.
00:0E:3C	TransactTe             # TransAct Technoloiges Inc.
00:0E:3D	TelevicNV              # Televic N.V.
00:0E:3E	SunOptroni             # Sun Optronics Inc
00:0E:3F	Soronti                # Soronti, Inc.
00:0E:40	NortelNetw             # Nortel Networks
00:0E:41	NihonMecha             # NIHON MECHATRONICS CO.,LTD.
00:0E:42	MoticIncop             # Motic Incoporation Ltd.
00:0E:43	G-TekElect             # G-Tek Electronics Sdn. Bhd.
00:0E:44	Digital5               # Digital 5, Inc.
00:0E:45	BeijingNew             # Beijing Newtry Electronic Technology Ltd
00:0E:46	NiigataSei             # Niigata Seimitsu Co.,Ltd.
00:0E:47	NciSystem              # NCI System Co.,Ltd.
00:0E:48	LipmanTran             # Lipman TransAction Solutions
00:0E:49	ForswaySca             # Forsway Scandinavia AB
00:0E:4A	ChangchunH             # Changchun Huayu WEBPAD Co.,LTD
00:0E:4B	AtriumCAnd             # atrium c and i
00:0E:4C	Bermai                 # Bermai Inc.
00:0E:4D	Numesa                 # Numesa Inc.
00:0E:4E	WaveplusTe             # Waveplus Technology Co., Ltd.
00:0E:4F	Trajet                 # Trajet GmbH
00:0E:50	ThomsonTel             # Thomson Telecom Belgium
00:0E:51	TecnaElett             # tecna elettronica srl
00:0E:52	Optium                 # Optium Corporation
00:0E:53	AvTech                 # AV TECH CORPORATION
00:0E:54	AlphacellW             # AlphaCell Wireless Ltd.
00:0E:55	Auvitran
00:0E:56	4g                     # 4G Systems GmbH
00:0E:57	IworldNetw             # Iworld Networking, Inc.
00:0E:58	Sonos                  # Sonos, Inc.
00:0E:59	SagemSa                # SAGEM SA
00:0E:5A	Telefield              # TELEFIELD inc.
00:0E:5B	Parkervisi             # ParkerVision - Direct2Data
00:0E:5C	MotorolaBc             # Motorola BCS
00:0E:5D	TriplePlay             # Triple Play Technologies A/S
00:0E:5E	BeijingRai             # Beijing Raisecom Science & Technology Development Co.,Ltd
00:0E:5F	Activ-Net              # activ-net GmbH & Co. KG
00:0E:60	360sunDigi             # 360SUN Digital Broadband Corporation
00:0E:61	Microtrol              # MICROTROL LIMITED
00:0E:62	NortelNetw             # Nortel Networks
00:0E:63	LemkeDiagn             # Lemke Diagnostics GmbH
00:0E:64	Elphel                 # Elphel, Inc
00:0E:65	Transcore
00:0E:66	HitachiAdv             # Hitachi Advanced Digital, Inc.
00:0E:67	EltisMicro             # Eltis Microelectronics Ltd.
00:0E:68	E-TopNetwo             # E-TOP Network Technology Inc.
00:0E:69	ChinaElect             # China Electric Power Research Institute
00:0E:6A	3comEurope             # 3COM EUROPE LTD
00:0E:6B	JanitzaEle             # Janitza electronics GmbH
00:0E:6C	DeviceDriv             # Device Drivers Limited
00:0E:6D	MurataManu             # Murata Manufacturing Co., Ltd.
00:0E:6E	MicrelecEl             # MICRELEC  ELECTRONICS S.A
00:0E:6F	IrisBerhad             # IRIS Corporation Berhad
00:0E:70	In2Network             # in2 Networks
00:0E:71	GemstarTec             # Gemstar Technology Development Ltd.
00:0E:72	CtsElectro             # CTS electronics
00:0E:73	Tpack                  # Tpack A/S
00:0E:74	SolarTelec             # Solar Telecom. Tech
00:0E:75	NewYorkAir             # New York Air Brake Corp.
00:0E:76	GemsocInno             # GEMSOC INNOVISION INC.
00:0E:77	Decru                  # Decru, Inc.
00:0E:78	Amtelco
00:0E:79	AmpleCommu             # Ample Communications Inc.
00:0E:7A	GemwonComm             # GemWon Communications Co., Ltd.
00:0E:7B	Toshiba
00:0E:7C	TelevesSA              # Televes S.A.
00:0E:7D	Electronic             # Electronics Line 3000 Ltd.
00:0E:7E	ComprogOy              # Comprog Oy
00:0E:7F	HewlettPac             # Hewlett Packard
00:0E:80	ThomsonTec             # Thomson Technology Inc
00:0E:81	Devicescap             # Devicescape Software, Inc.
00:0E:82	CommtechWi             # Commtech Wireless
00:0E:83	Cisco                  # Cisco Systems
00:0E:84	Cisco                  # Cisco Systems
00:0E:85	CatalystEn             # Catalyst Enterprises, Inc.
00:0E:86	AlcatelNor             # Alcatel North America
00:0E:87	AdpGauselm             # adp Gauselmann GmbH
00:0E:88	Videotron              # VIDEOTRON CORP.
00:0E:89	Clematic
00:0E:8A	AvaraTechn             # Avara Technologies Pty. Ltd.
00:0E:8B	AstarteTec             # Astarte Technology Co, Ltd.
00:0E:8C	SiemensA&D             # Siemens AG A&D ET
00:0E:8D	InProgress             # Systems in Progress Holding GmbH
00:0E:8E	SparklanCo             # SparkLAN Communications, Inc.
00:0E:8F	Sercomm                # Sercomm Corp.
00:0E:90	Ponico                 # PONICO CORP.
00:0E:91	NorthstarT             # Northstar Technologies
00:0E:92	Millinet               # Millinet Co., Ltd.
00:0E:93	Mil�Nio3Si             # Mil�nio 3 Sistemas Electr�nicos, Lda.
00:0E:94	MaasIntern             # Maas International BV
00:0E:95	FujiyaDenk             # Fujiya Denki Seisakusho Co.,Ltd.
00:0E:96	CubicDefen             # Cubic Defense Applications, Inc.
00:0E:97	UltrackerT             # Ultracker Technology CO., Inc
00:0E:98	VitecCc                # Vitec CC, INC.
00:0E:99	SpectrumDi             # Spectrum Digital, Inc
00:0E:9A	BoeTechnol             # BOE TECHNOLOGY GROUP CO.,LTD
00:0E:9B	AmbitMicro             # Ambit Microsystems Corporation
00:0E:9C	Pemstar
00:0E:9D	VideoNetwo             # Video Networks Ltd
00:0E:9E	Topfield               # Topfield Co., Ltd
00:0E:9F	TemicSds               # TEMIC SDS GmbH
00:0E:A0	NetklassTe             # NetKlass Technology Inc.
00:0E:A1	FormosaTel             # Formosa Teletek Corporation
00:0E:A2	Cyberguard             # CyberGuard Corporation
00:0E:A3	Cncr-ItHan             # CNCR-IT CO.,LTD,HangZhou P.R.CHINA
00:0E:A4	Certance               # Certance Inc.
00:0E:A5	Blip                   # BLIP Systems
00:0E:A6	AsustekCom             # ASUSTEK COMPUTER INC.
00:0E:A7	Endace                 # Endace Inc Ltd.
00:0E:A8	UnitedTech             # United Technologists Europe Limited
00:0E:A9	ShanghaiXu             # Shanghai Xun Shi Communications Equipment Ltd. Co.
00:0E:AA	Scalent                # Scalent Systems, Inc.
00:0E:AB	Octigabay              # OctigaBay Systems Corporation
00:0E:AC	MintronEnt             # MINTRON ENTERPRISE CO., LTD.
00:0E:AD	MetanoiaTe             # Metanoia Technologies, Inc.
00:0E:AE	GawellTech             # GAWELL TECHNOLOGIES CORP.
00:0E:AF	Castel
00:0E:B0	SolutionsR             # Solutions Radio BV
00:0E:B1	Newcotech              # Newcotech,Ltd
00:0E:B2	Micro-Rese             # Micro-Research Finland Oy
00:0E:B3	LefthandNe             # LeftHand Networks
00:0E:B4	GuangzhouG             # GUANGZHOU GAOKE COMMUNICATIONS TECHNOLOGY CO.LTD.
00:0E:B5	EcastleEle             # Ecastle Electronics Co., Ltd.
00:0E:B6	RiverbedTe             # Riverbed Technology, Inc.
00:0E:B7	Knovative              # Knovative, Inc.
00:0E:B8	Iiga                   # Iiga co.,Ltd
00:0E:B9	HashimotoE             # HASHIMOTO Electronics Industry Co.,Ltd.
00:0E:BA	HanmiSemic             # HANMI SEMICONDUCTOR CO., LTD.
00:0E:BB	EverbeeNet             # Everbee Networks
00:0E:BC	Cullmann               # Cullmann GmbH
00:0E:BD	BurdickAQu             # Burdick, a Quinton Compny
00:0E:BE	B&BElectro             # B&B Electronics Manufacturing Co.
00:0E:BF	Remsdaq                # Remsdaq Limited
00:0E:C0	NortelNetw             # Nortel Networks
00:0E:C1	MynahTechn             # MYNAH Technologies
00:0E:C2	LowranceEl             # Lowrance Electronics, Inc.
00:0E:C3	LogicContr             # Logic Controls, Inc.
00:0E:C4	IskraTrans             # Iskra Transmission d.d.
00:0E:C5	DigitalMul             # Digital Multitools Inc
00:0E:C6	AsixElectr             # ASIX ELECTRONICS CORP.
00:0E:C7	MotorolaKo             # Motorola Korea
00:0E:C8	Zoran                  # Zoran Corporation
00:0E:C9	YokoTechno             # YOKO Technology Corp.
00:0E:CA	Wtss                   # WTSS Inc
00:0E:CB	VinesysTec             # VineSys Technology
00:0E:CC	Tableau
00:0E:CD	Skov                   # SKOV A/S
00:0E:CE	SITTISPA               # S.I.T.T.I. S.p.A.
00:0E:CF	ProfibusNu             # PROFIBUS Nutzerorganisation e.V.
00:0E:D0	Privaris               # Privaris, Inc.
00:0E:D1	OsakaMicro             # Osaka Micro Computer.
00:0E:D2	Filtronic              # Filtronic plc
00:0E:D3	Epicenter              # Epicenter, Inc.
00:0E:D4	CresittInd             # CRESITT INDUSTRIE
00:0E:D5	Copan                  # COPAN Systems Inc.
00:0E:D6	Cisco                  # Cisco Systems
00:0E:D7	Cisco                  # Cisco Systems
00:0E:D8	Aktino                 # Aktino, Inc.
00:0E:D9	Aksys                  # Aksys, Ltd.
00:0E:DA	C-TechUnit             # C-TECH UNITED CORP.
00:0E:DB	Xincom                 # XiNCOM Corp.
00:0E:DC	Tellion                # Tellion INC.
00:0E:DD	Shure                  # SHURE INCORPORATED
00:0E:DE	Remec                  # REMEC, Inc.
00:0E:DF	PlxTechnol             # PLX Technology
00:0E:E0	Mcharge
00:0E:E1	Extremespe             # ExtremeSpeed Inc.
00:0E:E2	CustomEngi             # Custom Engineering S.p.A.
00:0E:E3	ChiyuTechn             # Chiyu Technology Co.,Ltd
00:0E:E4	BoeTechnol             # BOE TECHNOLOGY GROUP CO.,LTD
00:0E:E5	Bitwallet              # bitWallet, Inc.
00:0E:E6	Adimos                 # Adimos Systems LTD
00:0E:E7	AacElectro             # AAC ELECTRONICS CORP.
00:0E:E8	Zioncom
00:0E:E9	WaytechDev             # WayTech Development, Inc.
00:0E:EA	ShadongLun             # Shadong Luneng Jicheng Electronics,Co.,Ltd
00:0E:EB	Sandmartin             # Sandmartin(zhong shan)Electronics Co.,Ltd
00:0E:EC	Orban
00:0E:ED	NokiaDanma             # Nokia Danmark A/S
00:0E:EE	MucoIndust             # Muco Industrie BV
00:0E:EF	Private
00:0E:F0	Festo                  # Festo AG & Co. KG
00:0E:F1	Ezquest                # EZQUEST INC.
00:0E:F2	Infinico               # Infinico Corporation
00:0E:F3	Smarthome
00:0E:F4	ShenzhenKa             # Shenzhen Kasda Digital Technology Co.,Ltd
00:0E:F5	IpacTechno             # iPAC Technology Co., Ltd.
00:0E:F6	E-TenInfor             # E-TEN Information Systems Co., Ltd.
00:0E:F7	VulcanPort             # Vulcan Portals Inc
00:0E:F8	SbcAsi                 # SBC ASI
00:0E:F9	ReaElektro             # REA Elektronik GmbH
00:0E:FA	OptowayTec             # Optoway Technology Incorporation
00:0E:FB	MaceyEnter             # Macey Enterprises
00:0E:FC	JtagTechno             # JTAG Technologies B.V.
00:0E:FD	FujiPhotoO             # FUJI PHOTO OPTICAL CO., LTD.
00:0E:FE	EndrunTech             # EndRun Technologies LLC
00:0E:FF	Megasoluti             # Megasolution,Inc.
00:0F:00	Legra                  # Legra Systems, Inc.
00:0F:01	Digitalks              # DIGITALKS INC
00:0F:02	DigicubeTe             # Digicube Technology Co., Ltd
00:0F:03	Com&C                  # COM&C CO., LTD
00:0F:04	Cim-Usa                # cim-usa inc
00:0F:05	3bSystem               # 3B SYSTEM INC.
00:0F:06	NortelNetw             # Nortel Networks
00:0F:07	Mangrove               # Mangrove Systems, Inc.
00:0F:08	IndagonOy              # Indagon Oy
00:0F:09	Private
00:0F:0A	ClearEdgeN             # Clear Edge Networks
00:0F:0B	KentimaTec             # Kentima Technologies AB
00:0F:0C	Synchronic             # SYNCHRONIC ENGINEERING
00:0F:0D	HuntElectr             # Hunt Electronic Co., Ltd.
00:0F:0E	Wavesplitt             # WaveSplitter Technologies, Inc.
00:0F:0F	RealIdTech             # Real ID Technology Co., Ltd.
00:0F:10	Rdm                    # RDM Corporation
00:0F:11	ProdriveBV             # Prodrive B.V.
00:0F:12	PanasonicA             # Panasonic AVC Networks Germany GmbH
00:0F:13	Nisca                  # Nisca corporation
00:0F:14	Mindray                # Mindray Co., Ltd.
00:0F:15	Kjaerulff1             # Kjaerulff1 A/S
00:0F:16	JayHowTech             # JAY HOW TECHNOLOGY CO.,
00:0F:17	InstaElekt             # Insta Elektro GmbH
00:0F:18	Industrial             # Industrial Control Systems
00:0F:19	Guidant                # Guidant Corporation
00:0F:1A	GamingSupp             # Gaming Support B.V.
00:0F:1B	Ego                    # Ego Systems Inc.
00:0F:1C	DigitallWo             # DigitAll World Co., Ltd
00:0F:1D	CosmoTechs             # Cosmo Techs Co., Ltd.
00:0F:1E	ChengduKtE             # Chengdu KT Electric Co.of High & New Technology
00:0F:1F	WwPcbaTest             # WW PCBA Test
00:0F:20	HewlettPac             # Hewlett Packard
00:0F:21	Scientific             # Scientific Atlanta, Inc
00:0F:22	Helius                 # Helius, Inc.
00:0F:23	Cisco                  # Cisco Systems
00:0F:24	Cisco                  # Cisco Systems
00:0F:25	AimvalleyB             # AimValley B.V.
00:0F:26	Worldaccxx             # WorldAccxx  LLC
00:0F:27	TealElectr             # TEAL Electronics, Inc.
00:0F:28	Itronix                # Itronix Corporation
00:0F:29	Augmentix              # Augmentix Corporation
00:0F:2A	CablewareE             # Cableware Electronics
00:0F:2B	Greenbell              # GREENBELL SYSTEMS
00:0F:2C	Uplogix                # Uplogix, Inc.
00:0F:2D	Chung-Hsin             # CHUNG-HSIN ELECTRIC & MACHINERY MFG.CORP.
00:0F:2E	MegapowerI             # Megapower International Corp.
00:0F:2F	W-LinxTech             # W-LINX TECHNOLOGY CO., LTD.
00:0F:30	RazaMicroe             # Raza Microelectronics Inc
00:0F:31	Prosilica
00:0F:32	LutongElec             # LuTong Electronic Technology Co.,Ltd
00:0F:33	Duali                  # DUALi Inc.
00:0F:34	Cisco                  # Cisco Systems
00:0F:35	Cisco                  # Cisco Systems
00:0F:36	AccurateTe             # Accurate Techhnologies, Inc.
00:0F:37	Xambala                # Xambala Incorporated
00:0F:38	Netstar
00:0F:39	IrisSensor             # IRIS SENSORS
00:0F:3A	Hisharp
00:0F:3B	FujiSystem             # Fuji System Machines Co., Ltd.
00:0F:3C	Endeleo                # Endeleo Limited
00:0F:3D	D-Link                 # D-Link Corporation
00:0F:3E	Cardionet              # CardioNet, Inc
00:0F:3F	BigBearNet             # Big Bear Networks
00:0F:40	OpticalInt             # Optical Internetworking Forum
00:0F:41	Zipher                 # Zipher Ltd
00:0F:42	Xalyo                  # Xalyo Systems
00:0F:43	Wasabi                 # Wasabi Systems Inc.
00:0F:44	Tivella                # Tivella Inc.
00:0F:45	Stretch                # Stretch, Inc.
00:0F:46	Sinar                  # SINAR AG
00:0F:47	RoboxSpa               # ROBOX SPA
00:0F:48	Polypix                # Polypix Inc.
00:0F:49	NorthoverS             # Northover Solutions Limited
00:0F:4A	Kyushu-Kyo             # Kyushu-kyohan co.,ltd
00:0F:4B	KatanaTech             # Katana Technology
00:0F:4C	Elextech               # Elextech INC
00:0F:4D	Centrepoin             # Centrepoint Technologies Inc.
00:0F:4E	Cellink
00:0F:4F	CadmusTech             # Cadmus Technology Ltd
00:0F:50	Baxall                 # Baxall Limited
00:0F:51	Azul                   # Azul Systems, Inc.
00:0F:52	YorkRefrig             # YORK Refrigeration, Marine & Controls
00:0F:53	Level5Netw             # Level 5 Networks, Inc.
00:0F:54	Entrelogic             # Entrelogic Corporation
00:0F:55	DatawireCo             # Datawire Communication Networks Inc.
00:0F:56	ContinuumP             # Continuum Photonics Inc
00:0F:57	Cablelogic             # CABLELOGIC Co., Ltd.
00:0F:58	AdderTechn             # Adder Technology Limited
00:0F:59	PhonakComm             # Phonak Communications AG
00:0F:5A	PeribitNet             # Peribit Networks
00:0F:5B	DeltaInfor             # Delta Information Systems, Inc.
00:0F:5C	DayOneDigi             # Day One Digital Media Limited
00:0F:5D	42networks             # 42Networks AB
00:0F:5E	Veo
00:0F:5F	NicetyTech             # Nicety Technologies Inc. (NTS)
00:0F:60	Lifetron               # Lifetron Co.,Ltd
00:0F:61	KiwiNetwor             # Kiwi Networks
00:0F:62	AlcatelBel             # Alcatel Bell Space N.V.
00:0F:63	ObzervTech             # Obzerv Technologies
00:0F:64	D&RElectro             # D&R Electronica Weesp BV
00:0F:65	Icube                  # icube Corp.
00:0F:66	Cisco-Link             # Cisco-Linksys
00:0F:67	WestInstru             # West Instruments
00:0F:68	VavicNetwo             # Vavic Network Technology, Inc.
00:0F:69	SewEurodri             # SEW Eurodrive GmbH & Co. KG
00:0F:6A	NortelNetw             # Nortel Networks
00:0F:6B	GatewareCo             # GateWare Communications GmbH
00:0F:6C	Addi-Data              # ADDI-DATA GmbH
00:0F:6D	MidasEngin             # Midas Engineering
00:0F:6E	Bbox
00:0F:6F	FtaCommuni             # FTA Communication Technologies
00:0F:70	WintecIndu             # Wintec Industries, inc.
00:0F:71	SanmeiElec             # Sanmei Electronics Co.,Ltd
00:0F:72	Sandburst
00:0F:73	RockwellSa             # Rockwell Samsung Automation
00:0F:74	QamcomTech             # Qamcom Technology AB
00:0F:75	FirstSilic             # First Silicon Solutions
00:0F:76	DigitalKey             # Digital Keystone, Inc.
00:0F:77	Dentum                 # DENTUM CO.,LTD
00:0F:78	Datacap                # Datacap Systems Inc
00:0F:79	BluetoothI             # Bluetooth Interest Group Inc.
00:0F:7A	BeijingNuq             # BeiJing NuQX Technology CO.,LTD
00:0F:7B	ArceSistem             # Arce Sistemas, S.A.
00:0F:7C	Acti                   # ACTi Corporation
00:0F:7D	Xirrus
00:0F:7E	UisAblerEl             # UIS Abler Electronics Co.,Ltd.
00:0F:7F	Ubstorage              # UBSTORAGE Co.,Ltd.
00:0F:80	TrinitySec             # Trinity Security Systems,Inc.
00:0F:81	SecureInfo             # Secure Info Imaging
00:0F:82	MortaraIns             # Mortara Instrument, Inc.
00:0F:83	BrainiumTe             # Brainium Technologies Inc.
00:0F:84	AstuteNetw             # Astute Networks, Inc.
00:0F:85	Addo-Japan             # ADDO-Japan Corporation
00:0F:86	ResearchIn             # Research In Motion Limited
00:0F:87	MaxcessInt             # Maxcess International
00:0F:88	Ametek                 # AMETEK, Inc.
00:0F:89	WinnertecS             # Winnertec System Co., Ltd.
00:0F:8A	Wideview
00:0F:8B	OrionMulti             # Orion MultiSystems Inc
00:0F:8C	Gigawavete             # Gigawavetech Pte Ltd
00:0F:8D	FastTv-Ser             # FAST TV-Server AG
00:0F:8E	DongyangTe             # DONGYANG TELECOM CO.,LTD.
00:0F:8F	Cisco                  # Cisco Systems
00:0F:90	Cisco                  # Cisco Systems
00:0F:91	Aeroteleco             # Aerotelecom Co.,Ltd.
00:0F:92	Microhard              # Microhard Systems Inc.
00:0F:93	Landis+Gyr             # Landis+Gyr Ltd.
00:0F:94	Genexis
00:0F:95	ElecomLane             # ELECOM Co.,LTD Laneed Division
00:0F:96	CriticalTe             # Critical Telecom Corp.
00:0F:97	Avanex                 # Avanex Corporation
00:0F:98	Avamax                 # Avamax Co. Ltd.
00:0F:99	ApacOptoEl             # APAC opto Electronics Inc.
00:0F:9A	Synchrony              # Synchrony, Inc.
00:0F:9B	RossVideo              # Ross Video Limited
00:0F:9C	Panduit                # Panduit Corp
00:0F:9D	NewnhamRes             # Newnham Research Ltd
00:0F:9E	Murrelektr             # Murrelektronik GmbH
00:0F:9F	MotorolaBc             # Motorola BCS
00:0F:A0	CanonKorea             # CANON KOREA BUSINESS SOLUTIONS INC.
00:0F:A1	Gigabit                # Gigabit Systems Inc.
00:0F:A2	DigitalPat             # Digital Path Networks
00:0F:A3	AlphaNetwo             # Alpha Networks Inc.
00:0F:A4	SprecherAu             # Sprecher Automation GmbH
00:0F:A5	Smp/BwaTec             # SMP / BWA Technology GmbH
00:0F:A6	S2Security             # S2 Security Corporation
00:0F:A7	RaptorNetw             # Raptor Networks Technology
00:0F:A8	Photometri             # Photometrics, Inc.
00:0F:A9	PcFabrik               # PC Fabrik
00:0F:AA	NexusTechn             # Nexus Technologies
00:0F:AB	KyushuElec             # Kyushu Electronics Systems Inc.
00:0F:AC	Ieee80211              # IEEE 802.11
00:0F:AD	FmnCommuni             # FMN communications GmbH
00:0F:AE	E2oCommuni             # E2O Communications
00:0F:AF	Dialog                 # Dialog Inc.
00:0F:B0	CompalElec             # Compal Electronics,INC.
00:0F:B1	Cognio                 # Cognio Inc.
00:0F:B2	BroadbandP             # Broadband Pacenet (India) Pvt. Ltd.
00:0F:B3	ActiontecE             # Actiontec Electronics, Inc
00:0F:B4	TimespaceT             # Timespace Technology
00:0F:B5	Netgear                # NETGEAR Inc
00:0F:B6	EuroplexTe             # Europlex Technologies
00:0F:B7	CaviumNetw             # Cavium Networks
00:0F:B8	Callurl                # CallURL Inc.
00:0F:B9	AdaptiveIn             # Adaptive Instruments
00:0F:BA	Tevebox                # Tevebox AB
00:0F:BB	SiemensIcn             # Siemens AG, ICN M&L TDC EP
00:0F:BC	OnkeyTechn             # Onkey Technologies, Inc.
00:0F:BD	MrvCommuni             # MRV Communications (Networks) LTD
00:0F:BE	E-W/You                # e-w/you Inc.
00:0F:BF	DgtSpZOO               # DGT Sp. z o.o.
00:0F:C0	Delcomp
00:0F:C1	Wave                   # WAVE Corporation
00:0F:C2	Uniwell                # Uniwell Corporation
00:0F:C3	PalmpalmTe             # PalmPalm Technology, Inc.
00:0F:C4	Nst                    # NST co.,LTD.
00:0F:C5	Keymed                 # KeyMed Ltd
00:0F:C6	EurocomInd             # Eurocom Industries A/S
00:0F:C7	DionicaR&D             # Dionica R&D Ltd.
00:0F:C8	ChantryNet             # Chantry Networks
00:0F:C9	Allnet                 # Allnet GmbH
00:0F:CA	A-JinTechl             # A-JIN TECHLINE CO, LTD
00:0F:CB	3comEurope             # 3COM EUROPE LTD
00:0F:CC	Netopia                # Netopia, Inc.
00:0F:CD	NortelNetw             # Nortel Networks
00:0F:CE	KikusuiEle             # Kikusui Electronics Corp.
00:0F:CF	DatawindRe             # Datawind Research
00:0F:D0	Astri
00:0F:D1	AppliedWir             # Applied Wireless Identifications Group, Inc.
00:0F:D2	EwaTechnol             # EWA Technologies, Inc.
00:0F:D3	Digium
00:0F:D4	Soundcraft
00:0F:D5	Schwechat-             # Schwechat - RISE
00:0F:D6	Sarotech               # Sarotech Co., Ltd
00:0F:D7	HarmanMusi             # Harman Music Group
00:0F:D8	Force                  # Force, Inc.
00:0F:D9	FlexdslTel             # FlexDSL Telecommunications AG
00:0F:DA	Yazaki                 # YAZAKI CORPORATION
00:0F:DB	WestellTec             # Westell Technologies
00:0F:DC	UedaJapanR             # Ueda Japan  Radio Co., Ltd.
00:0F:DD	Sordin                 # SORDIN AB
00:0F:DE	SonyEricss             # Sony Ericsson Mobile Communications AB
00:0F:DF	SolomonTec             # SOLOMON Technology Corp.
00:0F:E0	Ncomputing             # NComputing Co.,Ltd.
00:0F:E1	IdDigital              # ID DIGITAL CORPORATION
00:0F:E2	HangzhouHu             # Hangzhou Huawei-3Com Tech. Co., Ltd.
00:0F:E3	DammCellul             # Damm Cellular Systems A/S
00:0F:E4	Pantech                # Pantech Co.,Ltd
00:0F:E5	MercurySec             # MERCURY SECURITY CORPORATION
00:0F:E6	Mbtech                 # MBTech Systems, Inc.
00:0F:E7	LutronElec             # Lutron Electronics Co., Inc.
00:0F:E8	Lobos                  # Lobos, Inc.
00:0F:E9	GwTechnolo             # GW TECHNOLOGIES CO.,LTD.
00:0F:EA	Giga-ByteT             # Giga-Byte Technology Co.,LTD.
00:0F:EB	CylonContr             # Cylon Controls
00:0F:EC	Arkus                  # Arkus Inc.
00:0F:ED	AnamElectr             # Anam Electronics Co., Ltd
00:0F:EE	Xtec                   # XTec, Incorporated
00:0F:EF	ThalesE-Tr             # Thales e-Transactions GmbH
00:0F:F0	SunrayEnte             # Sunray Enterprise
00:0F:F1	Nex-GPte               # nex-G Systems Pte.Ltd
00:0F:F2	LoudTechno             # Loud Technologies Inc.
00:0F:F3	JungMyoung             # Jung Myoung Communications&Technology
00:0F:F4	Guntermann             # Guntermann & Drunck GmbH
00:0F:F5	Gn&S                   # GN&S company
00:0F:F6	DarfonElec             # Darfon Electronics Corp.
00:0F:F7	Cisco                  # Cisco Systems
00:0F:F8	Cisco                  # Cisco  Systems
00:0F:F9	Valcretec              # Valcretec, Inc.
00:0F:FA	Optinel                # Optinel Systems, Inc.
00:0F:FB	NipponDens             # Nippon Denso Industry Co., Ltd.
00:0F:FC	MeritLi-Li             # Merit Li-Lin Ent.
00:0F:FD	GlorytekNe             # Glorytek Network Inc.
00:0F:FE	G-ProCompu             # G-PRO COMPUTER
00:0F:FF	Control4
00:10:00	CableTelev             # CABLE TELEVISION LABORATORIES, INC.
00:10:01	MckCommuni             # MCK COMMUNICATIONS
00:10:02	Actia
00:10:03	Imatron                # IMATRON, INC.
00:10:04	BrantleyCo             # THE BRANTLEY COILE COMPANY,INC
00:10:05	UecCommerc             # UEC COMMERCIAL
00:10:06	ThalesCont             # Thales Contact Solutions Ltd.
00:10:07	Cisco                  # CISCO SYSTEMS, INC.
00:10:08	Vienna                 # VIENNA SYSTEMS CORPORATION
00:10:09	HoroQuartz             # HORO QUARTZ
00:10:0A	WilliamsCo             # WILLIAMS COMMUNICATIONS GROUP
00:10:0B	Cisco                  # CISCO SYSTEMS, INC.
00:10:0C	Ito                    # ITO CO., LTD.
00:10:0D	Cisco                  # CISCO SYSTEMS, INC.
00:10:0E	MicroLinea             # MICRO LINEAR COPORATION
00:10:0F	Industrial             # INDUSTRIAL CPU SYSTEMS
00:10:10	Initio                 # INITIO CORPORATION
00:10:11	Cisco                  # CISCO SYSTEMS, INC.
00:10:12	ProcessorI             # PROCESSOR SYSTEMS (I) PVT LTD
00:10:13	Kontron
00:10:14	Cisco                  # CISCO SYSTEMS, INC.
00:10:15	Oomon                  # OOmon Inc.
00:10:16	TSqware                # T.SQWARE
00:10:17	Micos                  # MICOS GmbH
00:10:18	Broadcom               # BROADCOM CORPORATION
00:10:19	SironaDent             # SIRONA DENTAL SYSTEMS GmbH & Co. KG
00:10:1A	Picturetel             # PictureTel Corp.
00:10:1B	CornetTech             # CORNET TECHNOLOGY, INC.
00:10:1C	OhmTechnol             # OHM TECHNOLOGIES INTL, LLC
00:10:1D	WinbondEle             # WINBOND ELECTRONICS CORP.
00:10:1E	Matsushita             # MATSUSHITA ELECTRONIC INSTRUMENTS CORP.
00:10:1F	Cisco                  # CISCO SYSTEMS, INC.
00:10:20	WelchAllyn             # WELCH ALLYN, DATA COLLECTION
00:10:21	EncantoNet             # ENCANTO NETWORKS, INC.
00:10:22	SatcomMedi             # SatCom Media Corporation
00:10:23	FlowwiseNe             # FLOWWISE NETWORKS, INC.
00:10:24	NagoyaElec             # NAGOYA ELECTRIC WORKS CO., LTD
00:10:25	Grayhill               # GRAYHILL INC.
00:10:26	Accelerate             # ACCELERATED NETWORKS, INC.
00:10:27	L-3Communi             # L-3 COMMUNICATIONS EAST
00:10:28	ComputerTe             # COMPUTER TECHNICA, INC.
00:10:29	Cisco                  # CISCO SYSTEMS, INC.
00:10:2A	ZfMicrosys             # ZF MICROSYSTEMS, INC.
00:10:2B	UmaxData               # UMAX DATA SYSTEMS, INC.
00:10:2C	LasatNetwo             # Lasat Networks A/S
00:10:2D	HitachiSof             # HITACHI SOFTWARE ENGINEERING
00:10:2E	NetworkTec             # NETWORK SYSTEMS & TECHNOLOGIES PVT. LTD.
00:10:2F	Cisco                  # CISCO SYSTEMS, INC.
00:10:30	Eion                   # EION Inc.
00:10:31	ObjectiveC             # OBJECTIVE COMMUNICATIONS, INC.
00:10:32	AltaTechno             # ALTA TECHNOLOGY
00:10:33	AccesslanC             # ACCESSLAN COMMUNICATIONS, INC.
00:10:34	GnpCompute             # GNP Computers
00:10:35	Elitegroup             # ELITEGROUP COMPUTER SYSTEMS CO., LTD
00:10:36	Inter-TelI             # INTER-TEL INTEGRATED SYSTEMS
00:10:37	CyqVeTechn             # CYQ've Technology Co., Ltd.
00:10:38	MicroResea             # MICRO RESEARCH INSTITUTE, INC.
00:10:39	Vectron                # Vectron Systems AG
00:10:3A	DiamondNet             # DIAMOND NETWORK TECH
00:10:3B	HippiNetwo             # HIPPI NETWORKING FORUM
00:10:3C	IcEnsemble             # IC ENSEMBLE, INC.
00:10:3D	Phasecom               # PHASECOM, LTD.
00:10:3E	Netschools             # NETSCHOOLS CORPORATION
00:10:3F	TollgradeC             # TOLLGRADE COMMUNICATIONS, INC.
00:10:40	Intermec               # INTERMEC CORPORATION
00:10:41	BristolBab             # BRISTOL BABCOCK, INC.
00:10:42	Alacritech
00:10:43	A2                     # A2 CORPORATION
00:10:44	Innolabs               # InnoLabs Corporation
00:10:45	NortelNetw             # Nortel Networks
00:10:46	AlcornMcbr             # ALCORN MCBRIDE INC.
00:10:47	EchoEletri             # ECHO ELETRIC CO. LTD.
00:10:48	HtrcAutoma             # HTRC AUTOMATION, INC.
00:10:49	ShorelineT             # SHORELINE TELEWORKS, INC.
00:10:4A	Parvuc                 # THE PARVUC CORPORATION
00:10:4B	3com                   # 3COM CORPORATION
00:10:4C	ComputerAc             # COMPUTER ACCESS TECHNOLOGY
00:10:4D	SurtecIndu             # SURTEC INDUSTRIES, INC.
00:10:4E	Ceologic
00:10:4F	StorageTec             # STORAGE TECHNOLOGY CORPORATION
00:10:50	Rion                   # RION CO., LTD.
00:10:51	Cmicro                 # CMICRO CORPORATION
00:10:52	Mettler-To             # METTLER-TOLEDO (ALBSTADT) GMBH
00:10:53	ComputerTe             # COMPUTER TECHNOLOGY CORP.
00:10:54	Cisco                  # CISCO SYSTEMS, INC.
00:10:55	FujitsuMic             # FUJITSU MICROELECTRONICS, INC.
00:10:56	Sodick                 # SODICK CO., LTD.
00:10:57	RebelCom               # Rebel.com, Inc.
00:10:58	Arrowpoint             # ArrowPoint Communications
00:10:59	DiabloRese             # DIABLO RESEARCH CO. LLC
00:10:5A	3com                   # 3COM CORPORATION
00:10:5B	NetInsight             # NET INSIGHT AB
00:10:5C	QuantumDes             # QUANTUM DESIGNS (H.K.) LTD.
00:10:5D	DraegerMed             # Draeger Medical
00:10:5E	HekimianLa             # HEKIMIAN LABORATORIES, INC.
00:10:5F	In-Snec
00:10:60	Billionton             # BILLIONTON SYSTEMS, INC.
00:10:61	Hostlink               # HOSTLINK CORP.
00:10:62	NxServerIl             # NX SERVER, ILNC.
00:10:63	StarguideD             # STARGUIDE DIGITAL NETWORKS
00:10:64	DnpgLlc                # DNPG, LLC
00:10:65	Radyne                 # RADYNE CORPORATION
00:10:66	AdvancedCo             # ADVANCED CONTROL SYSTEMS, INC.
00:10:67	RedbackNet             # REDBACK NETWORKS, INC.
00:10:68	ComosTelec             # COMOS TELECOM
00:10:69	HeliossCom             # HELIOSS COMMUNICATIONS, INC.
00:10:6A	DigitalMic             # DIGITAL MICROWAVE CORPORATION
00:10:6B	SonusNetwo             # SONUS NETWORKS, INC.
00:10:6C	InfratecPl             # INFRATEC PLUS GmbH
00:10:6D	IntegrityC             # INTEGRITY COMMUNICATIONS, INC.
00:10:6E	TadiranCom             # TADIRAN COM. LTD.
00:10:6F	TrentonTec             # TRENTON TECHNOLOGY INC.
00:10:70	CaradonTre             # CARADON TREND LTD.
00:10:71	Advanet                # ADVANET INC.
00:10:72	GvnTechnol             # GVN TECHNOLOGIES, INC.
00:10:73	Technobox              # TECHNOBOX, INC.
00:10:74	AtenIntern             # ATEN INTERNATIONAL CO., LTD.
00:10:75	Maxtor                 # Maxtor Corporation
00:10:76	Eurem                  # EUREM GmbH
00:10:77	SafDrive               # SAF DRIVE SYSTEMS, LTD.
00:10:78	NueraCommu             # NUERA COMMUNICATIONS, INC.
00:10:79	Cisco                  # CISCO SYSTEMS, INC.
00:10:7A	Ambicom                # AmbiCom, Inc.
00:10:7B	Cisco                  # CISCO SYSTEMS, INC.
00:10:7C	P-Com                  # P-COM, INC.
00:10:7D	AuroraComm             # AURORA COMMUNICATIONS, LTD.
00:10:7E	BachmannEl             # BACHMANN ELECTRONIC GmbH
00:10:7F	CrestronEl             # CRESTRON ELECTRONICS, INC.
00:10:80	MetawaveCo             # METAWAVE COMMUNICATIONS
00:10:81	Dps                    # DPS, INC.
00:10:82	JnaTelecom             # JNA TELECOMMUNICATIONS LIMITED
00:10:83	Hewlett-Pa             # HEWLETT-PACKARD COMPANY
00:10:84	K-BotCommu             # K-BOT COMMUNICATIONS
00:10:85	PolarisCom             # POLARIS COMMUNICATIONS, INC.
00:10:86	AttoTechno             # ATTO TECHNOLOGY, INC.
00:10:87	Xstreamis              # Xstreamis PLC
00:10:88	AmericanNe             # AMERICAN NETWORKS INC.
00:10:89	Websonic
00:10:8A	Teralogic              # TeraLogic, Inc.
00:10:8B	Laseranima             # LASERANIMATION SOLLINGER GmbH
00:10:8C	FujitsuTel             # FUJITSU TELECOMMUNICATIONS EUROPE, LTD.
00:10:8D	JohnsonCon             # JOHNSON CONTROLS, INC.
00:10:8E	HughSymons             # HUGH SYMONS CONCEPT Technologies Ltd.
00:10:8F	Raptor                 # RAPTOR SYSTEMS
00:10:90	Cimetrics              # CIMETRICS, INC.
00:10:91	NoWiresNee             # NO WIRES NEEDED BV
00:10:92	Netcore                # NETCORE INC.
00:10:93	CmsCompute             # CMS COMPUTERS, LTD.
00:10:94	Performanc             # Performance Analysis Broadband, Spirent plc
00:10:95	Thomson                # Thomson Inc.
00:10:96	Tracewell              # TRACEWELL SYSTEMS, INC.
00:10:97	WinnetMetr             # WinNet Metropolitan Communications Systems, Inc.
00:10:98	StarnetTec             # STARNET TECHNOLOGIES, INC.
00:10:99	Innomedia              # InnoMedia, Inc.
00:10:9A	Netline
00:10:9B	Emulex                 # Emulex Corporation
00:10:9C	M-System               # M-SYSTEM CO., LTD.
00:10:9D	Clarinet               # CLARINET SYSTEMS, INC.
00:10:9E	Aware                  # AWARE, INC.
00:10:9F	Pavo                   # PAVO, INC.
00:10:A0	InnovexTec             # INNOVEX TECHNOLOGIES, INC.
00:10:A1	KendinSemi             # KENDIN SEMICONDUCTOR, INC.
00:10:A2	Tns
00:10:A3	Omnitronix             # OMNITRONIX, INC.
00:10:A4	Xircom
00:10:A5	OxfordInst             # OXFORD INSTRUMENTS
00:10:A6	Cisco                  # CISCO SYSTEMS, INC.
00:10:A7	UnexTechno             # UNEX TECHNOLOGY CORPORATION
00:10:A8	RelianceCo             # RELIANCE COMPUTER CORP.
00:10:A9	AdhocTechn             # ADHOC TECHNOLOGIES
00:10:AA	Media4                 # MEDIA4, INC.
00:10:AB	KoitoIndus             # KOITO INDUSTRIES, LTD.
00:10:AC	ImciTechno             # IMCI TECHNOLOGIES
00:10:AD	Softronics             # SOFTRONICS USB, INC.
00:10:AE	ShinkoElec             # SHINKO ELECTRIC INDUSTRIES CO.
00:10:AF	Tac                    # TAC SYSTEMS, INC.
00:10:B0	MeridianTe             # MERIDIAN TECHNOLOGY CORP.
00:10:B1	For-A                  # FOR-A CO., LTD.
00:10:B2	CoactiveAe             # COACTIVE AESTHETICS
00:10:B3	NokiaMulti             # NOKIA MULTIMEDIA TERMINALS
00:10:B4	Atmosphere             # ATMOSPHERE NETWORKS
00:10:B5	AcctonTech             # ACCTON TECHNOLOGY CORPORATION
00:10:B6	EntrataCom             # ENTRATA COMMUNICATIONS CORP.
00:10:B7	CoyoteTech             # COYOTE TECHNOLOGIES, LLC
00:10:B8	IshigakiCo             # ISHIGAKI COMPUTER SYSTEM CO.
00:10:B9	Maxtor                 # MAXTOR CORP.
00:10:BA	Martinho-D             # MARTINHO-DAVIS SYSTEMS, INC.
00:10:BB	DataInform             # DATA & INFORMATION TECHNOLOGY
00:10:BC	AastraTele             # Aastra Telecom
00:10:BD	Telecommun             # THE TELECOMMUNICATION TECHNOLOGY COMMITTEE
00:10:BE	Telexis                # TELEXIS CORP.
00:10:BF	InterairWi             # InterAir Wireless
00:10:C0	Arma                   # ARMA, INC.
00:10:C1	OiElectric             # OI ELECTRIC CO., LTD.
00:10:C2	Willnet                # WILLNET, INC.
00:10:C3	Csi-Contro             # CSI-CONTROL SYSTEMS
00:10:C4	MediaLinks             # MEDIA LINKS CO., LTD.
00:10:C5	ProtocolTe             # PROTOCOL TECHNOLOGIES, INC.
00:10:C6	Usi
00:10:C7	DataTransm             # DATA TRANSMISSION NETWORK
00:10:C8	Communicat             # COMMUNICATIONS ELECTRONICS SECURITY GROUP
00:10:C9	Mitsubishi             # MITSUBISHI ELECTRONICS LOGISTIC SUPPORT CO.
00:10:CA	IntegralAc             # INTEGRAL ACCESS
00:10:CB	FacitKK                # FACIT K.K.
00:10:CC	ClpCompute             # CLP COMPUTER LOGISTIK PLANUNG GmbH
00:10:CD	InterfaceC             # INTERFACE CONCEPT
00:10:CE	Volamp                 # VOLAMP, LTD.
00:10:CF	FiberlaneC             # FIBERLANE COMMUNICATIONS
00:10:D0	Witcom                 # WITCOM, LTD.
00:10:D1	TopLayerNe             # Top Layer Networks, Inc.
00:10:D2	NittoTsush             # NITTO TSUSHINKI CO., LTD
00:10:D3	GripsElect             # GRIPS ELECTRONIC GMBH
00:10:D4	StorageCom             # STORAGE COMPUTER CORPORATION
00:10:D5	ImasdeCana             # IMASDE CANARIAS, S.A.
00:10:D6	Itt-A/Cd               # ITT - A/CD
00:10:D7	ArgosyRese             # ARGOSY RESEARCH INC.
00:10:D8	Calista
00:10:D9	IbmJapanFu             # IBM JAPAN, FUJISAWA MT+D
00:10:DA	MotionEngi             # MOTION ENGINEERING, INC.
00:10:DB	Netscreen		# Now part of Juniper Networks
00:10:DC	Micro-Star             # MICRO-STAR INTERNATIONAL CO., LTD.
00:10:DD	EnableSemi             # ENABLE SEMICONDUCTOR, INC.
00:10:DE	Internatio             # INTERNATIONAL DATACASTING CORPORATION
00:10:DF	RiseComput             # RISE COMPUTER INC.
00:10:E0	CobaltMicr             # COBALT MICROSERVER, INC.
00:10:E1	SITech                 # S.I. TECH, INC.
00:10:E2	Arraycomm              # ArrayComm, Inc.
00:10:E3	CompaqComp             # COMPAQ COMPUTER CORPORATION
00:10:E4	Nsi                    # NSI CORPORATION
00:10:E5	SolectronT             # SOLECTRON TEXAS
00:10:E6	AppliedInt             # APPLIED INTELLIGENT SYSTEMS, INC.
00:10:E7	Breezecom
00:10:E8	Telocity               # TELOCITY, INCORPORATED
00:10:E9	Raidtec                # RAIDTEC LTD.
00:10:EA	AdeptTechn             # ADEPT TECHNOLOGY
00:10:EB	Selsius                # SELSIUS SYSTEMS, INC.
00:10:EC	RpcgLlc                # RPCG, LLC
00:10:ED	SundanceTe             # SUNDANCE TECHNOLOGY, INC.
00:10:EE	CtiProduct             # CTI PRODUCTS, INC.
00:10:EF	Dbtel                  # DBTEL INCORPORATED
00:10:F1	I-O                    # I-O CORPORATION
00:10:F2	Antec
00:10:F3	NexcomInte             # Nexcom International Co., Ltd.
00:10:F4	VerticalNe             # VERTICAL NETWORKS, INC.
00:10:F5	Amherst                # AMHERST SYSTEMS, INC.
00:10:F6	Cisco                  # CISCO SYSTEMS, INC.
00:10:F7	IriichiTec             # IRIICHI TECHNOLOGIES Inc.
00:10:F8	KenwoodTmi             # KENWOOD TMI CORPORATION
00:10:F9	Unique                 # UNIQUE SYSTEMS, INC.
00:10:FA	Zayante                # ZAYANTE, INC.
00:10:FB	ZidaTechno             # ZIDA TECHNOLOGIES LIMITED
00:10:FC	BroadbandN             # BROADBAND NETWORKS, INC.
00:10:FD	Cocom                  # COCOM A/S
00:10:FE	DigitalEqu             # DIGITAL EQUIPMENT CORPORATION
00:10:FF	Cisco                  # CISCO SYSTEMS, INC.
00:11:00	RamIndustr             # RAM Industries, LLC
00:11:01	CetTechnol             # CET Technologies Pte Ltd
00:11:02	AuroraMult             # Aurora Multimedia Corp.
00:11:03	KawamuraEl             # kawamura electric inc.
00:11:04	Telexy
00:11:05	SunplusTec             # Sunplus Technology Co., Ltd.
00:11:06	SiemensNvB             # Siemens NV (Belgium)
00:11:07	RgbNetwork             # RGB Networks Inc.
00:11:08	OrbitalDat             # Orbital Data Corporation
00:11:09	Micro-Star             # Micro-Star International
00:11:0A	HewlettPac             # Hewlett Packard
00:11:0B	FranklinTe             # Franklin Technology Systems
00:11:0C	AtmarkTech             # Atmark Techno, Inc.
00:11:0D	SanblazeTe             # SANBlaze Technology, Inc.
00:11:0E	TsurusakiS             # Tsurusaki Sealand Transportation Co. Ltd.
00:11:0F	Netplat                # netplat,Inc.
00:11:10	MaxannaTec             # Maxanna Technology Co., Ltd.
00:11:11	Intel                  # Intel Corporation
00:11:12	HoneywellC             # Honeywell CMSS
00:11:13	Fraunhofer             # Fraunhofer FOKUS
00:11:14	EverfocusE             # EverFocus Electronics Corp.
00:11:15	EpinTechno             # EPIN Technologies, Inc.
00:11:16	CoteauVert             # COTEAU VERT CO., LTD.
00:11:17	Cesnet
00:11:18	BlxIcDesig             # BLX IC Design Corp., Ltd.
00:11:19	Solteras               # Solteras, Inc.
00:11:1A	MotorolaBc             # Motorola BCS
00:11:1B	TargaDivL-             # Targa Systems Div L-3 Communications Canada
00:11:1C	PleoraTech             # Pleora Technologies Inc.
00:11:1D	Hectrix                # Hectrix Limited
00:11:1E	EpsgEthern             # EPSG (Ethernet Powerlink Standardization Group)
00:11:1F	DoremiLabs             # Doremi Labs, Inc.
00:11:20	Cisco                  # Cisco Systems
00:11:21	Cisco                  # Cisco Systems
00:11:22	Cimsys                 # CIMSYS Inc
00:11:23	Appointech             # Appointech, Inc.
00:11:24	AppleCompu             # Apple Computer
00:11:25	Ibm                    # IBM Corporation
00:11:26	Venstar                # Venstar Inc.
00:11:27	Tasi                   # TASI, Inc
00:11:28	Streamit
00:11:29	ParadiseDa             # Paradise Datacom Ltd.
00:11:2A	NikoNv                 # Niko NV
00:11:2B	Netmodule
00:11:2C	Izt                    # IZT GmbH
00:11:2D	GuysWithou             # Guys Without Ties
00:11:2E	Ceicom
00:11:2F	AsustekCom             # ASUSTek Computer Inc.
00:11:30	AlliedTele             # Allied Telesis (Hong Kong) Ltd.
00:11:31	Unatech                # UNATECH. CO.,LTD
00:11:32	Synology               # Synology Incorporated
00:11:33	SiemensAus             # Siemens Austria SIMEA
00:11:34	Mediacell              # MediaCell, Inc.
00:11:35	Grandeye               # Grandeye Ltd
00:11:36	GoodrichSe             # Goodrich Sensor Systems
00:11:37	AichiElect             # AICHI ELECTRIC CO., LTD.
00:11:38	Taishin                # TAISHIN CO., LTD.
00:11:39	StoeberAnt             # STOEBER ANTRIEBSTECHNIK GmbH + Co. KG.
00:11:3A	Shinboram
00:11:3B	MicronetCo             # Micronet Communications Inc.
00:11:3C	Micronas               # Micronas GmbH
00:11:3D	KnSoltec               # KN SOLTEC CO.,LTD.
00:11:3E	Jl                     # JL Corporation
00:11:3F	AlcatelDi              # Alcatel DI
00:11:40	Nanometric             # Nanometrics Inc.
00:11:41	Goodman                # GoodMan Corporation
00:11:42	E-Smartcom             # e-SMARTCOM  INC.
00:11:43	Dell                   # DELL INC.
00:11:44	AssuranceT             # Assurance Technology Corp
00:11:45	Valuepoint             # ValuePoint Networks
00:11:46	Telecard-P             # Telecard-Pribor Ltd
00:11:47	Secom-Indu             # Secom-Industry co.LTD.
00:11:48	ProlonCont             # Prolon Control Systems
00:11:49	ProliphixL             # Proliphix LLC
00:11:4A	KayabaIndu             # KAYABA INDUSTRY Co,.Ltd.
00:11:4B	Francotyp-             # Francotyp-Postalia AG & Co. KG
00:11:4C	CaffeinaAp             # caffeina applied research ltd.
00:11:4D	AtsumiElec             # Atsumi Electric Co.,LTD.
00:11:4E	690885Onta             # 690885 Ontario Inc.
00:11:4F	UsDigitalT             # US Digital Television, Inc
00:11:50	Belkin                 # Belkin Corporation
00:11:51	Mykotronx
00:11:52	EidsvollEl             # Eidsvoll Electronics AS
00:11:53	TridentTek             # Trident Tek, Inc.
00:11:54	WebproTech             # Webpro Technologies Inc.
00:11:55	Sevis                  # Sevis Systems
00:11:56	PharosNz               # Pharos Systems NZ
00:11:57	OfNetworks             # OF Networks Co., Ltd.
00:11:58	NortelNetw             # Nortel Networks
00:11:59	MatisseNet             # MATISSE NETWORKS INC
00:11:5A	IvoclarViv             # Ivoclar Vivadent AG
00:11:5B	Elitegroup             # Elitegroup Computer System Co. (ECS)
00:11:5C	Cisco
00:11:5D	Cisco
00:11:5E	ProminentD             # ProMinent Dosiertechnik GmbH
00:11:5F	Intellix               # Intellix Co., Ltd.
00:11:60	Artdio                 # ARTDIO Company Co., LTD
00:11:61	Netstreams             # NetStreams, LLC
00:11:62	StarMicron             # STAR MICRONICS CO.,LTD.
00:11:63	SystemSpaD             # SYSTEM SPA DEPT. ELECTRONICS
00:11:64	AcardTechn             # ACARD Technology Corp.
00:11:65	ZnyxNetwor             # Znyx Networks
00:11:66	TaelimElec             # Taelim Electronics Co., Ltd.
00:11:67	Integrated             # Integrated System Solution Corp.
00:11:68	HomelogicL             # HomeLogic LLC
00:11:69	EmsSatcom              # EMS Satcom
00:11:6A	Domo                   # Domo Ltd
00:11:6B	DigitalDat             # Digital Data Communications Asia Co.,Ltd
00:11:6C	NanwangMul             # Nanwang Multimedia Inc.,Ltd
00:11:6D	AmericanTi             # American Time and Signal
00:11:6E	Peplink                # PePLink Ltd.
00:11:6F	Netforyou              # Netforyou Co., LTD.
00:11:70	GscSrl                 # GSC SRL
00:11:71	DexterComm             # DEXTER Communications, Inc.
00:11:72	Cotron                 # COTRON CORPORATION
00:11:73	Adtron                 # Adtron Corporation
00:11:74	WibhuTechn             # Wibhu Technologies, Inc.
00:11:75	Pathscale              # PathScale, Inc.
00:11:76	Intellambd             # Intellambda Systems, Inc.
00:11:77	CoaxialNet             # COAXIAL NETWORKS, INC.
00:11:78	ChironTech             # Chiron Technology Ltd
00:11:79	SingularTe             # Singular Technology Co. Ltd.
00:11:7A	SingimInte             # Singim International Corp.
00:11:7B	B�ChiLabor             # B�chi Labortechnik AG
00:11:7C	E-ZyNet                # e-zy.net
00:11:7D	ZmdAmerica             # ZMD America, Inc.
00:11:7E	Progeny                # Progeny Inc.
00:11:7F	NeotuneInf             # Neotune Information Technology Corporation,.LTD
00:11:80	MotorolaBc             # Motorola BCS
00:11:81	Interenerg             # InterEnergy Co.Ltd,
00:11:82	ImiNorgren             # IMI Norgren Ltd
00:11:83	PscScannin             # PSC Scanning, Inc
00:11:84	HumoLabora             # Humo Laboratory,Ltd.
00:11:85	HewlettPac             # Hewlett Packard
00:11:86	Prime                  # Prime Systems, Inc.
00:11:87	CategorySo             # Category Solutions, Inc
00:11:88	Enterasys
00:11:89	Aerotech               # Aerotech Inc
00:11:8A	ViewtranTe             # Viewtran Technology Limited
00:11:8B	Netdevices             # NetDevices Inc.
00:11:8C	MissouriDe             # Missouri Department of Transportation
00:11:8D	HanchangSy             # Hanchang System Corp.
00:11:8E	HalytechMa             # Halytech Mace
00:11:8F	EutechInst             # EUTECH INSTRUMENTS PTE. LTD.
00:11:90	DigitalDes             # Digital Design Corporation
00:11:91	Cts-ClimaT             # CTS-Clima Temperatur Systeme GmbH
00:11:92	Cisco                  # Cisco Systems
00:11:93	Cisco                  # Cisco Systems
00:11:94	ChiMeiComm             # Chi Mei Communication Systems, Inc.
00:11:95	D-Link                 # D-Link Corporation
00:11:96	Actuality              # Actuality Systems, Inc.
00:11:97	Monitoring             # Monitoring Technologies Limited
00:11:98	PrismMedia             # Prism Media Products Limited
00:11:99	2wcom                  # 2wcom GmbH
00:11:9A	AlkeriaSrl             # Alkeria srl
00:11:9B	Telesynerg             # Telesynergy Research Inc.
00:11:9C	Ep&TEnergy             # EP&T Energy
00:11:9D	DiginfoTec             # Diginfo Technology Corporation
00:11:9E	SolectronB             # Solectron Brazil
00:11:9F	NokiaDanma             # Nokia Danmark A/S
00:11:A0	VtechEngin             # Vtech Engineering Canada Ltd
00:11:A1	VisionNetw             # VISION NETWARE CO.,LTD
00:11:A2	Manufactur             # Manufacturing Technology Inc
00:11:A3	LanreadyTe             # LanReady Technologies Inc.
00:11:A4	JstreamTec             # JStream Technologies Inc.
00:11:A5	FortunaEle             # Fortuna Electronic Corp.
00:11:A6	SypixxNetw             # Sypixx Networks
00:11:A7	InfilcoDeg             # Infilco Degremont Inc.
00:11:A8	QuestTechn             # Quest Technologies
00:11:A9	Moimstone              # MOIMSTONE Co., LTD
00:11:AA	UniclassTe             # Uniclass Technology, Co., LTD
00:11:AB	TrustableT             # TRUSTABLE TECHNOLOGY CO.,LTD.
00:11:AC	SimtecElec             # Simtec Electronics
00:11:AD	ShanghaiRu             # Shanghai Ruijie Technology
00:11:AE	MotorolaBc             # Motorola BCS
00:11:AF	Medialink-             # Medialink-i,Inc
00:11:B0	Fortelink              # Fortelink Inc.
00:11:B1	Blueexpert             # BlueExpert Technology Corp.
00:11:B2	2001Techno             # 2001 Technology Inc.
00:11:B3	Yoshimiya              # YOSHIMIYA CO.,LTD.
00:11:B4	WestermoTe             # Westermo Teleindustri AB
00:11:B5	ShenzhenPo             # Shenzhen Powercom Co.,Ltd
00:11:B6	OpenIntern             # Open Systems International
00:11:B7	MelexisNed             # Melexis Nederland B.V.
00:11:B8	Liebherr-E             # Liebherr - Elektronik GmbH
00:11:B9	InnerRange             # Inner Range Pty. Ltd.
00:11:BA	ElexolPty              # Elexol Pty Ltd
00:11:BB	Cisco                  # Cisco Systems
00:11:BC	Cisco                  # Cisco Systems
00:11:BD	Bombardier             # Bombardier Transportation
00:11:BE	AgpTelecom             # AGP Telecom Co. Ltd
00:11:BF	AesysSPA               # AESYS S.p.A.
00:11:C0	AdayTechno             # Aday Technology Inc
00:11:C1	4pMobileDa             # 4P MOBILE DATA PROCESSING
00:11:C2	UnitedFibe             # United Fiber Optic Communication
00:11:C3	Transceivi             # Transceiving System Technology Corporation
00:11:C4	Terminales             # Terminales de Telecomunicacion Terrestre, S.L.
00:11:C5	TenTechnol             # TEN Technology
00:11:C6	SeagateTec             # Seagate Technology LLC
00:11:C7	RaymarineG             # RAYMARINE Group Ltd.
00:11:C8	Powercom               # Powercom Co., Ltd.
00:11:C9	Mtt                    # MTT Corporation
00:11:CA	LongRange              # Long Range Systems, Inc.
00:11:CB	JacobsonsR             # Jacobsons RKH AB
00:11:CC	GuangzhouJ             # Guangzhou Jinpeng Group Co.,Ltd.
00:11:CD	AxsunTechn             # Axsun Technologies
00:11:CE	Ubisense               # Ubisense Limited
00:11:CF	ThraneThra             # Thrane & Thrane A/S
00:11:D0	TandbergDa             # Tandberg Data ASA
00:11:D1	SoftImagin             # Soft Imaging System GmbH
00:11:D2	Perception             # Perception Digital Ltd
00:11:D3	Nextgentel             # NextGenTel Holding ASA
00:11:D4	Netenrich              # NetEnrich, Inc
00:11:D5	HangzhouSu             # Hangzhou Sunyard System Engineering Co.,Ltd.
00:11:D6	Handera                # HandEra, Inc.
00:11:D7	Ewerks                 # eWerks Inc
00:11:D8	AsustekCom             # ASUSTek Computer Inc.
00:11:D9	Tivo
00:11:DA	VivaasTech             # Vivaas Technology Inc.
00:11:DB	Land-Cellu             # Land-Cellular Corporation
00:11:DC	GlunzJense             # Glunz & Jensen
00:11:DD	FromusTec              # FROMUS TEC. Co., Ltd.
00:11:DE	Eurilogic
00:11:DF	Arecont                # Arecont Systems
00:11:E0	U-MediaCom             # U-MEDIA Communications, Inc.
00:11:E1	BekoElectr             # BEKO Electronics Co.
00:11:E2	HuaJungCom             # Hua Jung Components Co., Ltd.
00:11:E3	Thomson                # Thomson, Inc.
00:11:E4	DanelecEle             # Danelec Electronics A/S
00:11:E5	Kcodes                 # KCodes Corporation
00:11:E6	Scientific             # Scientific Atlanta
00:11:E7	Worldsat-T             # WORLDSAT - Texas de France
00:11:E8	TixiCom                # Tixi.Com
00:11:E9	Starnex                # STARNEX CO., LTD.
00:11:EA	Iwics                  # IWICS Inc.
00:11:EB	Innovative             # Innovative Integration
00:11:EC	Avix                   # AVIX INC.
00:11:ED	802Global              # 802 Global
00:11:EE	Estari                 # Estari, Inc.
00:11:EF	ConitecDat             # Conitec Datensysteme GmbH
00:11:F0	Wideful                # Wideful Limited
00:11:F1	Qinetiq                # QinetiQ Ltd
00:11:F2	InstituteO             # Institute of Network Technologies
00:11:F3	GavitecAg-             # Gavitec AG- mobile digit
00:11:F4	Woori-Net
00:11:F5	AskeyCompu             # ASKEY COMPUTER CORP.
00:11:F6	AsiaPacifi             # Asia Pacific Microsystems , Inc.
00:11:F7	ShenzhenFo             # Shenzhen Forward Industry Co., Ltd
00:11:F8	Airaya                 # AIRAYA Corp
00:11:F9	NortelNetw             # Nortel Networks
00:11:FA	Rane                   # Rane Corporation
00:11:FB	Heidelberg             # Heidelberg Engineering GmbH
00:11:FC	HartingEle             # HARTING Electric Gmbh & Co.KG
00:11:FD	Korg                   # KORG INC.
00:11:FE	KeiyoSyste             # Keiyo System Research, Inc.
00:11:FF	DigitroTec             # Digitro Tecnologia Ltda
00:12:00	Cisco
00:12:01	Cisco
00:12:02	AudioInter             # Audio International Inc.
00:12:03	ActivNetwo             # Activ Networks
00:12:04	U10Network             # u10 Networks, Inc.
00:12:05	TerrasatCo             # Terrasat Communications, Inc.
00:12:06	IquestNz               # iQuest (NZ) Ltd
00:12:07	HeadStrong             # Head Strong International Limited
00:12:08	GantnerEle             # Gantner Electronic GmbH
00:12:09	Fastrax                # Fastrax Ltd
00:12:0A	EmersonEle             # Emerson Electric GmbH & Co. OHG
00:12:0B	ChinasysTe             # Chinasys Technologies Limited
00:12:0C	Ce-Infosys             # CE-Infosys Pte Ltd
00:12:0D	AdvancedTe             # Advanced Telecommunication Technologies, Inc.
00:12:0E	Abocom
00:12:0F	Ieee8023               # IEEE 802.3
00:12:10	Wideray                # WideRay Corp
00:12:11	ProtechnaH             # Protechna Herbst GmbH & Co. KG
00:12:12	PlusVision             # PLUS Vision Corporation
00:12:13	Metrohm                # Metrohm AG
00:12:14	KoenigBaue             # Koenig & Bauer AG
00:12:15	IstorNetwo             # iStor Networks, Inc.
00:12:16	IcpInterne             # ICP Internet Communication Payment AG
00:12:17	Cisco-Link             # Cisco-Linksys, LLC
00:12:18	Aruze                  # ARUZE Corporation
00:12:19	AheadCommu             # Ahead Communication Systems Inc
00:12:1A	TechnoSoft             # Techno Soft Systemnics Inc.
00:12:1B	SoundDevic             # Sound Devices, LLC
00:12:1C	ParrotSA               # PARROT S.A.
00:12:1D	Netfabric              # Netfabric Corporation
00:12:1E	JuniperNet             # Juniper Networks, Inc.
00:12:1F	HardingInt             # Harding Intruments
00:12:20	Cadco                  # Cadco Systems
00:12:21	BBraunMels             # B.Braun Melsungen AG
00:12:22	SkardinUk              # Skardin (UK) Ltd
00:12:23	Pixim
00:12:24	Nexql                  # NexQL Corporation
00:12:25	MotorolaBc             # Motorola BCS
00:12:26	JapanDirex             # Japan Direx Corporation
00:12:27	FranklinEl             # Franklin Electric Co., Inc.
00:12:28	Data                   # Data Ltd.
00:12:29	BroadeasyT             # BroadEasy Technologies Co.,Ltd
00:12:2A	VtechTelec             # VTech Telecommunications Ltd.
00:12:2B	VirbiagePt             # Virbiage Pty Ltd
00:12:2C	SoenenCont             # Soenen Controls N.V.
00:12:2D	Sinett                 # SiNett Corporation
00:12:2E	SignalTech             # Signal Technology - AISD
00:12:2F	SaneiElect             # Sanei Electric Inc.
00:12:30	PicasoInfo             # Picaso Infocommunication CO., LTD.
00:12:31	MotionCont             # Motion Control Systems, Inc.
00:12:32	LewizCommu             # LeWiz Communications Inc.
00:12:33	JrcTokki               # JRC TOKKI Co.,Ltd.
00:12:34	CamilleBau             # Camille Bauer
00:12:35	Andrew                 # Andrew Corporation
00:12:36	TidalNetwo             # Tidal Networks
00:12:37	TexasInstr             # Texas Instruments
00:12:38	SetaboxTec             # SetaBox Technology Co., Ltd.
00:12:39	SNet                   # S Net Systems Inc.
00:12:3A	Posystech              # Posystech Inc., Co.
00:12:3B	KeroAps                # KeRo Systems ApS
00:12:3C	Ip3Network             # IP3 Networks, Inc.
00:12:3D	Ges
00:12:3E	EruneTechn             # ERUNE technology Co., Ltd.
00:12:3F	Dell                   # Dell Inc
00:12:40	AmoiElectr             # AMOI ELECTRONICS CO.,LTD
00:12:41	A2iMarketi             # a2i marketing center
00:12:42	Millennial             # Millennial Net
00:12:43	Cisco
00:12:44	Cisco
00:12:45	ZellwegerA             # Zellweger Analytics, Inc.
00:12:46	TOMTechnol             # T.O.M TECHNOLOGY INC..
00:12:47	SamsungEle             # Samsung Electronics Co., Ltd.
00:12:48	Kashya                 # Kashya Inc.
00:12:49	DeltaElett             # Delta Elettronica S.p.A.
00:12:4A	DedicatedD             # Dedicated Devices, Inc.
00:12:4B	ChipconAs              # Chipcon AS
00:12:4C	Bbwm                   # BBWM Corporation
00:12:4D	InduconBv              # Inducon BV
00:12:4E	XacAutomat             # XAC AUTOMATION CORP.
00:12:4F	TycoTherma             # Tyco Thermal Controls LLC.
00:12:50	TokyoAirca             # Tokyo Aircaft Instrument Co., Ltd.
00:12:51	Silink
00:12:52	CitronixLl             # Citronix, LLC
00:12:53	Audiodev               # AudioDev AB
00:12:54	SpectraTec             # Spectra Technologies Holdings Company Ltd
00:12:55	Neteffect              # NetEffect Incorporated
00:12:56	LgInformat             # LG INFORMATION & COMM.
00:12:57	LeapcommCo             # LeapComm Communication Technologies Inc.
00:12:58	ActivisPol             # Activis Polska
00:12:59	ThermoElec             # THERMO ELECTRON KARLSRUHE
00:12:5A	Microsoft              # Microsoft Corporation
00:12:5B	KaimeiElec             # KAIMEI ELECTRONI
00:12:5C	GreenHills             # Green Hills Software, Inc.
00:12:5D	Cybernet               # CyberNet Inc.
00:12:5E	Caen
00:12:5F	Awind                  # AWIND Inc.
00:12:60	StantonMag             # Stanton Magnetics,inc.
00:12:61	Adaptix                # Adaptix, Inc
00:12:62	NokiaDanma             # Nokia Danmark A/S
00:12:63	DataVoiceT             # Data Voice Technologies GmbH
00:12:64	DaumElectr             # daum electronic gmbh
00:12:65	EnerdyneTe             # Enerdyne Technologies, Inc.
00:12:66	Private
00:12:67	Matsushita             # Matsushita Electronic Components Co., Ltd.
00:12:68	IpsDOO                 # IPS d.o.o.
00:12:69	ValueElect             # Value Electronics
00:12:6A	Optoelectr             # OPTOELECTRONICS Co., Ltd.
00:12:6B	AscaladeCo             # Ascalade Communications Limited
00:12:6C	Visonic                # Visonic Ltd.
00:12:6D	University             # University of California, Berkeley
00:12:6E	SeidelElek             # Seidel Elektronik GmbH Nfg.KG
00:12:6F	RaysonTech             # Rayson Technology Co., Ltd.
00:12:70	NgesDenro              # NGES Denro Systems
00:12:71	Measuremen             # Measurement Computing Corp
00:12:72	ReduxCommu             # Redux Communications Ltd.
00:12:73	Stoke                  # Stoke Inc
00:12:74	NitLab                 # NIT lab
00:12:75	Moteiv                 # Moteiv Corporation
00:12:76	MicrosolHo             # Microsol Holdings Ltd.
00:12:77	KorenixTec             # Korenix Technologies Co., Ltd.
00:12:78	Internatio             # International Bar Code
00:12:79	HewlettPac             # Hewlett Packard
00:12:7A	SanyuIndus             # Sanyu Industry Co.,Ltd.
00:12:7B	ViaNetwork             # VIA Networking Technologies, Inc.
00:12:7C	Swegon                 # SWEGON AB
00:12:7D	Mobilearia
00:12:7E	DigitalLif             # Digital Lifestyles Group, Inc.
00:12:7F	Cisco
00:12:80	Cisco
00:12:81	CieffeSrl              # CIEFFE srl
00:12:82	Qovia
00:12:83	NortelNetw             # Nortel Networks
00:12:84	Lab33Srl               # Lab33 Srl
00:12:85	GizmondoEu             # Gizmondo Europe Ltd
00:12:86	Endevco                # ENDEVCO CORP
00:12:87	DigitalEve             # Digital Everywhere Unterhaltungselektronik GmbH
00:12:88	2wire                  # 2Wire, Inc
00:12:89	AdvanceSte             # Advance Sterilization Products
00:12:8A	MotorolaPc             # Motorola PCS
00:12:8B	SensoryNet             # Sensory Networks Inc
00:12:8C	WoodwardGo             # Woodward Governor
00:12:8D	StbDatense             # STB Datenservice GmbH
00:12:8E	Q-FreeAsa              # Q-Free ASA
00:12:8F	Montilio
00:12:90	KyowaElect             # KYOWA Electric & Machinery Corp.
00:12:91	KwsCompute             # KWS Computersysteme GmbH
00:12:92	GriffinTec             # Griffin Technology
00:12:93	GeEnergy               # GE Energy
00:12:94	EudynaDevi             # Eudyna Devices Inc.
00:12:95	Aiware                 # Aiware Inc.
00:12:96	Addlogix
00:12:97	O2micro                # O2Micro, Inc.
00:12:98	MicoElectr             # MICO ELECTRIC(SHENZHEN) LIMITED
00:12:99	KtechTelec             # Ktech Telecommunications Inc
00:12:9A	IrtElectro             # IRT Electronics Pty Ltd
00:12:9B	E2sElectro             # E2S Electronic Engineering Solutions, S.L.
00:12:9C	Yulinet
00:12:9D	FirstInter             # FIRST INTERNATIONAL COMPUTER DO BRASIL LTDA
00:12:9E	SurfCommun             # Surf Communications Inc.
00:12:9F	Rae                    # RAE Systems, Inc.
00:12:A0	Neomeridia             # NeoMeridian Sdn Bhd
00:12:A1	Bluepacket             # BluePacket Communications Co., Ltd.
00:12:A2	Vita
00:12:A3	TrustInter             # Trust International B.V.
00:12:A4	Thingmagic             # ThingMagic, LLC
00:12:A5	Stargen                # Stargen, Inc.
00:12:A6	LakeTechno             # Lake Technology Ltd
00:12:A7	IsrTechnol             # ISR TECHNOLOGIES Inc
00:12:A8	Intec                  # intec GmbH
00:12:A9	3comEurope             # 3COM EUROPE LTD
00:12:AA	Iee                    # IEE, Inc.
00:12:AB	Wilife                 # WiLife, Inc.
00:12:AC	Ontimetek              # ONTIMETEK INC.
00:12:AD	Ids                    # IDS GmbH
00:12:AE	HlsHard-Li             # HLS HARD-LINE Solutions Inc.
00:12:AF	ElproTechn             # ELPRO Technologies
00:12:B0	EforeOyj               # Efore Oyj   (Plc)
00:12:B1	DaiNipponP             # Dai Nippon Printing Co., Ltd
00:12:B2	Avolites               # AVOLITES LTD.
00:12:B3	AdvanceWir             # Advance Wireless Technology Corp.
00:12:B4	Work                   # Work GmbH
00:12:B5	Vialta                 # Vialta, Inc.
00:12:B6	SantaBarba             # Santa Barbara Infrared, Inc.
00:12:B7	PtwFreibur             # PTW Freiburg
00:12:B8	G2Microsys             # G2 Microsystems
00:12:B9	FusionDigi             # Fusion Digital Technology
00:12:BA	Fsi                    # FSI Systems, Inc.
00:12:BB	Telecommun             # Telecommunications Industry Association TR-41 Committee
00:12:BC	EcholabLlc             # Echolab LLC
00:12:BD	AvantecMan             # Avantec Manufacturing Limited
00:12:BE	Astek                  # Astek Corporation
00:12:BF	ArcadyanTe             # Arcadyan Technology Corporation
00:12:C0	Hotlava                # HotLava Systems, Inc.
00:12:C1	CheckPoint             # Check Point Software Technologies
00:12:C2	ApexElectr             # Apex Electronics Factory
00:12:C3	WitSA                  # WIT S.A.
00:12:C4	Viseon                 # Viseon, Inc.
00:12:C5	V-ShowTech             # V-Show Technology Co.Ltd
00:12:C6	TgcAmerica             # TGC America, Inc
00:12:C7	SecurayTec             # SECURAY Technologies Ltd.Co.
00:12:C8	PerfectTec             # Perfect tech
00:12:C9	MotorolaBc             # Motorola BCS
00:12:CA	HansenTele             # Hansen Telecom
00:12:CB	Css                    # CSS Inc.
00:12:CC	Bitatek                # Bitatek CO., LTD
00:12:CD	AsemSpa                # ASEM SpA
00:12:CE	AdvancedCy             # Advanced Cybernetics Group
00:12:CF	AcctonTech             # Accton Technology Corporation
00:12:D0	Gossen-Met             # Gossen-Metrawatt-GmbH
00:12:D1	TexasInstr             # Texas Instruments Inc
00:12:D2	TexasInstr             # Texas Instruments
00:12:D3	Zetta                  # Zetta Systems, Inc.
00:12:D4	PrincetonT             # Princeton Technology, Ltd
00:12:D5	MotionReal             # Motion Reality Inc.
00:12:D6	JiangsuYit             # Jiangsu Yitong High-Tech Co.,Ltd
00:12:D7	InventoNet             # Invento Networks, Inc.
00:12:D8	Internatio             # International Games System Co., Ltd.
00:12:D9	Cisco                  # Cisco Systems
00:12:DA	Cisco                  # Cisco Systems
00:12:DB	ZiehlIndus             # ZIEHL industrie-elektronik GmbH + Co KG
00:12:DC	SuncorpInd             # SunCorp Industrial Limited
00:12:DD	ShengquInf             # Shengqu Information Technology (Shanghai) Co., Ltd.
00:12:DE	RadioCompo             # Radio Components Sweden AB
00:12:DF	Novomatic              # Novomatic AG
00:12:E0	Codan                  # Codan Limited
00:12:E1	AlliantNet             # Alliant Networks, Inc
00:12:E2	AlaxalaNet             # ALAXALA Networks Corporation
00:12:E3	Agat-Rt                # Agat-RT, Ltd.
00:12:E4	ZiehlIndus             # ZIEHL industrie-electronik GmbH + Co KG
00:12:E5	TimeAmeric             # Time America, Inc.
00:12:E6	SpectecCom             # SPECTEC COMPUTER CO., LTD.
00:12:E7	ProjectekN             # Projectek Networking Electronics Corp.
00:12:E8	Fraunhofer             # Fraunhofer IMS
00:12:E9	Abbey                  # Abbey Systems Ltd
00:12:EA	Trane
00:12:EB	R2diLlc                # R2DI, LLC
00:12:EC	MovacolorB             # Movacolor b.v.
00:12:ED	AvgAdvance             # AVG Advanced Technologies
00:12:EE	SonyEricss             # Sony Ericsson Mobile Communications AB
00:12:EF	OneaccessS             # OneAccess SA
00:12:F0	IntelCorpo             # Intel Corporate
00:12:F1	Ifotec
00:12:F2	FoundryNet             # Foundry Networks
00:12:F3	Connectblu             # connectBlue AB
00:12:F4	BelcoInter             # Belco International Co.,Ltd.
00:12:F5	Prolificx              # Prolificx Ltd
00:12:F6	Mdk                    # MDK CO.,LTD.
00:12:F7	XiamenXing             # Xiamen Xinglian Electronics Co., Ltd.
00:12:F8	WniResourc             # WNI Resources, LLC
00:12:F9	UryuSeisak             # URYU SEISAKU, LTD.
00:12:FA	Thx                    # THX LTD
00:12:FB	SamsungEle             # Samsung Electronics
00:12:FC	PlanetSyst             # PLANET System Co.,LTD
00:12:FD	OptimusIcS             # OPTIMUS IC S.A.
00:12:FE	LenovoMobi             # Lenovo Mobile Communication Technology Ltd.
00:12:FF	LelyIndust             # Lely Industries N.V.
00:13:00	It-Factory             # IT-FACTORY, INC.
00:13:01	IrongateSL             # IronGate S.L.
00:13:02	IntelCorpo             # Intel Corporate
00:13:03	Gateconnec             # GateConnect Technologies GmbH
00:13:04	FlaircommT             # Flaircomm Technologies Co. LTD
00:13:05	Epicom                 # Epicom, Inc.
00:13:06	AlwaysOnWi             # Always On Wireless
00:13:07	Paravirtua             # Paravirtual Corporation
00:13:08	NuveraFuel             # Nuvera Fuel Cells
00:13:09	OceanBroad             # Ocean Broadband Networks
00:13:0A	Nortel
00:13:0B	MextalBV               # Mextal B.V.
00:13:0C	HfSystem               # HF System Corporation
00:13:0D	GalileoAvi             # GALILEO AVIONICA
00:13:0E	FocusriteA             # Focusrite Audio Engineering Limited
00:13:0F	EgemenBilg             # EGEMEN Bilgisayar Muh San ve Tic LTD STI
00:13:10	Cisco-Link             # Cisco-Linksys, LLC
00:13:11	ArrisInter             # ARRIS International
00:13:12	AmediaNetw             # Amedia Networks Inc.
00:13:13	GuangzhouP             # GuangZhou Post & Telecom Equipment ltd
00:13:14	Asiamajor              # Asiamajor Inc.
00:13:15	SonyComput             # SONY Computer Entertainment inc,
00:13:16	L-S-B                  # L-S-B GmbH
00:13:17	GnNetcomAs             # GN Netcom as
00:13:18	Dgstation              # DGSTATION Co., Ltd.
00:13:19	Cisco                  # Cisco Systems
00:13:1A	Cisco                  # Cisco Systems
00:13:1B	BecellInno             # BeCell Innovations Corp.
00:13:1C	Litetouch              # LiteTouch, Inc.
00:13:1D	ScanvaegtI             # Scanvaegt International A/S
00:13:1E	PeikerAcus             # Peiker acustic GmbH & Co. KG
00:13:1F	NxtphaseT&             # NxtPhase T&D, Corp.
00:13:20	IntelCorpo             # Intel Corporate
00:13:21	HewlettPac             # Hewlett Packard
00:13:22	DaqElectro             # DAQ Electronics, Inc.
00:13:23	Cap                    # Cap Co., Ltd.
00:13:24	SchneiderE             # Schneider Electric Ultra Terminal
00:13:25	Immenstar              # ImmenStar Inc.
00:13:26	Ecm                    # ECM Systems Ltd
00:13:27	DataAcquis             # Data Acquisitions limited
00:13:28	WestechKor             # Westech Korea Inc.,
00:13:29	Vsst                   # VSST Co., LTD
00:13:2A	StromTelec             # STROM telecom, s. r. o.
00:13:2B	PhoenixDig             # Phoenix Digital
00:13:2C	MazBranden             # MAZ Brandenburg GmbH
00:13:2D	IwiseCommu             # iWise Communications Pty Ltd
00:13:2E	ItianCopor             # ITian Coporation
00:13:2F	Interactek
00:13:30	EuroProtec             # EURO PROTECTION SURVEILLANCE
00:13:31	CellpointC             # CellPoint Connect
00:13:32	BeijingTop             # Beijing Topsec Network Security Technology Co., Ltd.
00:13:33	BaudTechno             # Baud Technology Inc.
00:13:34	Arkados                # Arkados, Inc.
00:13:35	VsIndustry             # VS Industry Berhad
00:13:36	Tianjin712             # Tianjin 712 Communication Broadcasting co., ltd.
00:13:37	OrientPowe             # Orient Power Home Network Ltd.
00:13:38	Fresenius-             # FRESENIUS-VIAL
00:13:39	El-Me                  # EL-ME AG
00:13:3A	Vadatech               # VadaTech Inc.
00:13:3B	SpeedDrago             # Speed Dragon Multimedia Limited
00:13:3C	Quintron               # QUINTRON SYSTEMS INC.
00:13:3D	MicroMemor             # Micro Memory LLC
00:13:3E	Metaswitch
00:13:3F	EppendorfI             # Eppendorf Instrumente GmbH
00:13:40	AdElSRL                # AD.EL s.r.l.
00:13:41	ShandongNe             # Shandong New Beiyang Information Technology Co.,Ltd
00:13:42	VisionRese             # Vision Research, Inc.
00:13:43	Matsushita             # Matsushita Electronic Components (Europe) GmbH
00:13:44	FargoElect             # Fargo Electronics Inc.
00:13:45	Eaton                  # Eaton Corporation
00:13:46	D-Link                 # D-Link Corporation
00:13:47	BluetreeWi             # BlueTree Wireless Data Inc.
00:13:48	ArtilaElec             # Artila Electronics Co., Ltd.
00:13:49	ZyxelCommu             # ZyXEL Communications Corporation
00:13:4A	Engim                  # Engim, Inc.
00:13:4B	Togoldenne             # ToGoldenNet Technology Inc.
00:13:4C	YdtTechnol             # YDT Technology International
00:13:4D	Ipc                    # IPC systems
00:13:4E	Valox                  # Valox Systems, Inc.
00:13:4F	TranzeoWir             # Tranzeo Wireless Technologies Inc.
00:13:50	SilverSpri             # Silver Spring Networks, Inc
00:13:51	NilesAudio             # Niles Audio Corporation
00:13:52	Naztec                 # Naztec, Inc.
00:13:53	HydacFilte             # HYDAC Filtertechnik GMBH
00:13:54	ZcomaxTech             # Zcomax Technologies, Inc.
00:13:55	TomenCyber             # TOMEN Cyber-business Solutions, Inc.
00:13:56	TargetSyst             # target systemelectronic gmbh
00:13:57	SoyalTechn             # Soyal Technology Co., Ltd.
00:13:58	Realm                  # Realm Systems, Inc.
00:13:59	Protelevis             # ProTelevision Technologies A/S
00:13:5A	ProjectT&E             # Project T&E Limited
00:13:5B	PanellinkC             # PanelLink Cinema, LLC
00:13:5C	Onsite                 # OnSite Systems, Inc.
00:13:5D	NttpcCommu             # NTTPC Communications, Inc.
00:13:5E	Eab/Rwi/K
00:13:5F	Cisco                  # Cisco Systems
00:13:60	Cisco                  # Cisco Systems
00:13:61	Biospace               # Biospace Co., Ltd.
00:13:62	ShinheungP             # ShinHeung Precision Co., Ltd.
00:13:63	Verascape              # Verascape, Inc.
00:13:64	ParadigmTe             # Paradigm Technology Inc..
00:13:65	Nortel
00:13:66	NeturityTe             # Neturity Technologies Inc.
00:13:67	Narayon                # Narayon. Co., Ltd.
00:13:68	MaerskData             # Maersk Data Defence
00:13:69	HondaElect             # Honda Electron Co., LED.
00:13:6A	HachUltraA             # Hach Ultra Analytics
00:13:6B	E-Tec
00:13:6C	Private
00:13:6D	Tentaculus             # Tentaculus AB
00:13:6E	Techmetro              # Techmetro Corp.
00:13:6F	Packetmoti             # PacketMotion, Inc.
00:13:70	NokiaDanma             # Nokia Danmark A/S
00:13:71	MotorolaCh             # Motorola CHS
00:13:72	Dell                   # Dell Inc.
00:13:73	BlwaveElec             # BLwave Electronics Co., Ltd
00:13:74	AttansicTe             # Attansic Technology Corp.
00:13:75	AmericanSe             # American Security Products Co.
00:13:76	TaborElect             # Tabor Electronics Ltd.
00:13:77	SamsungEle             # Samsung Electronics CO., LTD
00:13:78	QsanTechno             # QSAN Technology, Inc.
00:13:79	PonderInfo             # PONDER INFORMATION INDUSTRIES LTD.
00:13:7A	NetvoxTech             # Netvox Technology Co., Ltd.
00:13:7B	Movon                  # Movon Corporation
00:13:7C	Kaicom                 # Kaicom co., Ltd.
00:13:7D	Dynalab                # Dynalab, Inc.
00:13:7E	CoredgeNet             # CorEdge Networks, Inc.
00:13:7F	Cisco                  # Cisco Systems
00:13:80	Cisco                  # Cisco Systems
00:13:81	Chips                  # CHIPS & Systems, Inc.
00:13:82	CetaceaNet             # Cetacea Networks Corporation
00:13:83	Applicatio             # Application Technologies and Engineering Research Laboratory
00:13:84	AdvancedMo             # Advanced Motion Controls
00:13:85	Add-OnTech             # Add-On Technology Co., LTD.
00:13:86	Abb/Totalf             # ABB Inc./Totalflow
00:13:87	27mTechnol             # 27M Technologies AB
00:13:88	WimediaAll             # WiMedia Alliance
00:13:89	RedesDeTel             # Redes de Telefon�a M�vil S.A.
00:13:8A	QingdaoGoe             # QINGDAO GOERTEK ELECTRONICS CO.,LTD.
00:13:8B	PhantomTec             # Phantom Technologies LLC
00:13:8C	Kumyoung               # Kumyoung.Co.Ltd
00:13:8D	Kinghold
00:13:8E	FoabElektr             # FOAB Elektronik AB
00:13:8F	AsiarockIn             # Asiarock Incorporation
00:13:90	TermtekCom             # Termtek Computer Co., Ltd
00:13:91	Ouen                   # OUEN CO.,LTD.
00:13:92	Video54Tec             # Video54 Technologies, Inc
00:13:93	Panta                  # Panta Systems, Inc.
00:13:94	Infohand               # Infohand Co.,Ltd
00:13:95	Congatec               # congatec AG
00:13:96	AcbelPolyt             # Acbel Polytech Inc.
00:13:97	Xsigo                  # Xsigo Systems, Inc.
00:13:98	Trafficsim             # TrafficSim Co.,Ltd
00:13:99	Stac                   # STAC Corporation.
00:13:9A	K-UbiqueId             # K-ubique ID Corp.
00:13:9B	Ioimage                # ioIMAGE Ltd.
00:13:9C	ExaveraTec             # Exavera Technologies, Inc.
00:13:9D	DesignOfOn             # Design of Systems on Silicon S.A.
00:13:9E	CiaraTechn             # Ciara Technologies Inc.
00:13:9F	Electronic             # Electronics Design Services, Co., Ltd.
00:13:A0	Algosystem             # ALGOSYSTEM Co., Ltd.
00:13:A1	CrowElectr             # Crow Electronic Engeneering
00:13:A2	Maxstream              # MaxStream, Inc
00:13:A3	SiemensCom             # Siemens Com CPE Devices
00:13:A4	KeyeyeComm             # KeyEye Communications
00:13:A5	GeneralSol             # General Solutions, LTD.
00:13:A6	Extricom               # Extricom Ltd
00:13:A7	BattelleMe             # BATTELLE MEMORIAL INSTITUTE
00:13:A8	TanisysTec             # Tanisys Technology
00:13:A9	Sony                   # Sony Corporation
00:13:AA	AlsTec                 # ALS  & TEC Ltd.
00:13:AB	Telemotive             # Telemotive AG
00:13:AC	SunmyungEl             # Sunmyung Electronics Co., LTD
00:13:AD	Sendo                  # Sendo Ltd
00:13:AE	RadianceTe             # Radiance Technologies
00:13:AF	NumaTechno             # NUMA Technology,Inc.
00:13:B0	Jablotron
00:13:B1	Intelligen             # Intelligent Control Systems (Asia) Pte Ltd
00:13:B2	Carallon               # Carallon Limited
00:13:B3	BeijingEco             # Beijing Ecom Communications Technology Co., Ltd.
00:13:B4	AppearTv               # Appear TV
00:13:B5	Wavesat
00:13:B6	SlingMedia             # Sling Media, Inc.
00:13:B7	ScantechId             # Scantech ID
00:13:B8	RycoElectr             # RyCo Electronic Systems Limited
00:13:B9	BmSpa                  # BM SPA
00:13:BA	Readylinks             # ReadyLinks Inc
00:13:BB	Private
00:13:BC	Artimi                 # Artimi Ltd
00:13:BD	HymatomSa              # HYMATOM SA
00:13:BE	VirtualCon             # Virtual Conexions
00:13:BF	MediaSyste             # Media System Planning Corp.
00:13:C0	TrixTecnol             # Trix Tecnologia Ltda.
00:13:C1	AsokaUsa               # Asoka USA Corporation
00:13:C2	Wacom                  # WACOM Co.,Ltd
00:13:C3	Cisco                  # Cisco Systems
00:13:C4	Cisco                  # Cisco Systems
00:13:C5	LightronFi             # LIGHTRON FIBER-OPTIC DEVICES INC.
00:13:C6	Opengear               # OpenGear, Inc
00:13:C7	Ionos                  # IONOS Co.,Ltd.
00:13:C8	PirelliBro             # PIRELLI BROADBAND SOLUTIONS S.P.A.
00:13:C9	BeyondAchi             # Beyond Achieve Enterprises Ltd.
00:13:CA	X-Digital              # X-Digital Systems, Inc.
00:13:CB	ZenitelNor             # Zenitel Norway AS
00:13:CC	TallMaple              # Tall Maple Systems
00:13:CD	Mti                    # MTI co. LTD
00:13:CE	IntelCorpo             # Intel Corporate
00:13:CF	4accessCom             # 4Access Communications
00:13:D0	E-San                  # e-San Limited
00:13:D1	KirkTeleco             # KIRK telecom A/S
00:13:D2	PageIberic             # PAGE IBERICA, S.A.
00:13:D3	Micro-Star             # MICRO-STAR INTERNATIONAL CO., LTD.
00:13:D4	AsustekCom             # ASUSTek COMPUTER INC.
00:13:D5	Winetworks             # WiNetworks LTD
00:13:D6	TiiNetwork             # TII NETWORK TECHNOLOGIES, INC.
00:13:D7	SpidcomTec             # SPIDCOM Technologies SA
00:13:D8	PrincetonI             # Princeton Instruments
00:13:D9	MatrixProd             # Matrix Product Development, Inc.
00:13:DA	Diskware               # Diskware Co., Ltd
00:13:DB	ShoeiElect             # SHOEI Electric Co.,Ltd
00:13:DC	Ibtek                  # IBTEK INC.
00:13:DD	AbbottDiag             # Abbott Diagnostics
00:13:DE	Adapt4
00:13:DF	Ryvor                  # Ryvor Corp.
00:13:E0	MurataManu             # Murata Manufacturing Co., Ltd.
00:13:E1	Iprobe
00:13:E2	Geovision              # GeoVision Inc.
00:13:E3	CoviTechno             # CoVi Technologies, Inc.
00:13:E4	Yangjae                # YANGJAE SYSTEMS CORP.
00:13:E5	Tenosys                # TENOSYS, INC.
00:13:E6	Technoluti             # Technolution
00:13:E7	MinelabEle             # Minelab Electronics Pty Limited
00:13:E8	IntelCorpo             # Intel Corporate
00:13:E9	Veriwave               # VeriWave, Inc.
00:13:EA	Kamstrup               # Kamstrup A/S
00:13:EB	Sysmaster              # Sysmaster Corporation
00:13:EC	SunbaySoft             # Sunbay Software AG
00:13:ED	Psia
00:13:EE	JbxDesigns             # JBX Designs Inc.
00:13:EF	KingjonDig             # Kingjon Digital Technology Co.,Ltd
00:13:F0	WavefrontS             # Wavefront Semiconductor
00:13:F1	AmodTechno             # AMOD Technology Co., Ltd.
00:13:F2	Klas                   # Klas Ltd
00:13:F3	Giga-ByteC             # Giga-byte Communications Inc.
00:13:F4	PsitekPty              # Psitek (Pty) Ltd
00:13:F5	Akimbi                 # Akimbi Systems
00:13:F6	Cintech
00:13:F7	SmcNetwork             # SMC Networks, Inc.
00:13:F8	DexSecurit             # Dex Security Solutions
00:13:F9	Cavera                 # Cavera Systems
00:13:FA	LifesizeCo             # LifeSize Communications, Inc
00:13:FB	RkcInstrum             # RKC INSTRUMENT INC.
00:13:FC	Sicortex               # SiCortex, Inc
00:13:FD	NokiaDanma             # Nokia Danmark A/S
00:13:FE	GrandtecEl             # GRANDTEC ELECTRONIC CORP.
00:13:FF	Dage-MtiOf             # Dage-MTI of MC, Inc.
00:14:00	MinervaKor             # MINERVA KOREA CO., LTD
00:14:01	RivertreeN             # Rivertree Networks Corp.
00:14:02	Kk-Electro             # kk-electronic a/s
00:14:03	RenasisLlc             # Renasis, LLC
00:14:04	MotorolaCh             # Motorola CHS
00:14:05	Openib                 # OpenIB, Inc.
00:14:06	GoNetworks             # Go Networks
00:14:07	Biosystems
00:14:08	Eka                    # Eka Systems Inc.
00:14:09	MagnetiMar             # MAGNETI MARELLI   S.E. S.p.A.
00:14:0A	Wepio                  # WEPIO Co., Ltd.
00:14:0B	FirstInter             # FIRST INTERNATIONAL COMPUTER, INC.
00:14:0C	GkbCctv                # GKB CCTV CO., LTD.
00:14:0D	Nortel
00:14:0E	Nortel
00:14:0F	FederalSta             # Federal State Unitary Enterprise Leningrad R&D Institute of
00:14:10	SuzhouKeda             # Suzhou Keda Technology CO.,Ltd
00:14:11	Deutschman             # Deutschmann Automation GmbH & Co. KG
00:14:12	S-TecElect             # S-TEC electronics AG
00:14:13	TrebingHim             # Trebing & Himstedt Prozessautomation GmbH & Co. KG
00:14:14	JumpnodeLl             # Jumpnode Systems LLC.
00:14:15	IntecAutom             # Intec Automation Inc.
00:14:16	ScoscheInd             # Scosche Industries, Inc.
00:14:17	RseInforma             # RSE Informations Technologie GmbH
00:14:18	C4line
00:14:19	Sidsa
00:14:1A	Deicy                  # DEICY CORPORATION
00:14:1B	Cisco                  # Cisco Systems
00:14:1C	Cisco                  # Cisco Systems
00:14:1D	LustAntrie             # Lust Antriebstechnik GmbH
00:14:1E	PASemi                 # P.A. Semi, Inc.
00:14:1F	SunkwangEl             # SunKwang Electronics Co., Ltd
00:14:20	G-LinksNet             # G-Links networking company
00:14:21	TotalWirel             # Total Wireless Technologies Pte. Ltd.
00:14:22	Dell                   # Dell Inc.
00:14:23	J-SNeuroco             # J-S Co. NEUROCOM
00:14:24	MerryElect             # Merry Electrics CO., LTD.
00:14:25	GalacticCo             # Galactic Computing Corp.
00:14:26	NlTechnolo             # NL Technology
00:14:27	Jazzmutant
00:14:28	Vocollect              # Vocollect, Inc
00:14:29	VCenterTec             # V Center Technologies Co., Ltd.
00:14:2A	Elitegroup             # Elitegroup Computer System Co., Ltd
00:14:2B	EdataTechn             # Edata Technologies Inc.
00:14:2C	KonceptInt             # Koncept International, Inc.
00:14:2D	Toradex                # Toradex AG
00:14:2E	77Elektron             # 77 Elektronika Kft.
00:14:2F	Wildpacket             # WildPackets
00:14:30	Vipower                # ViPowER, Inc
00:14:31	PdlElectro             # PDL Electronics Ltd
00:14:32	TarallaxWi             # Tarallax Wireless, Inc.
00:14:33	EmpowerTec             # Empower Technologies(Canada) Inc.
00:14:34	Keri                   # Keri Systems, Inc
00:14:35	Citycom                # CityCom Corp.
00:14:36	QwertyElek             # Qwerty Elektronik AB
00:14:37	Gsteletech             # GSTeletech Co.,Ltd.
00:14:38	HewlettPac             # Hewlett Packard
00:14:39	BlonderTon             # Blonder Tongue Laboratories, Inc.
00:14:3A	RaytalkInt             # RAYTALK INTERNATIONAL SRL
00:14:3B	Sensovatio             # Sensovation AG
00:14:3C	OerlikonCo             # Oerlikon Contraves Inc.
00:14:3D	Aevoe                  # Aevoe Inc.
00:14:3E	AirlinkCom             # AirLink Communications, Inc.
00:14:3F	HotwayTech             # Hotway Technology Corporation
00:14:40	Atomic                 # ATOMIC Corporation
00:14:41	Innovation             # Innovation Sound Technology Co., LTD.
00:14:42	Atto                   # ATTO CORPORATION
00:14:43	Consultron             # Consultronics Europe Ltd
00:14:44	GrundfosEl             # Grundfos Electronics
00:14:45	Telefon-Gr             # Telefon-Gradnja d.o.o.
00:14:46	Kidmapper              # KidMapper, Inc.
00:14:47	Boaz                   # BOAZ Inc.
00:14:48	InventecMu             # Inventec Multimedia & Telecom Corporation
00:14:49	SichuanCha             # Sichuan Changhong Electric Ltd.
00:14:4A	TaiwanThic             # Taiwan Thick-Film Ind. Corp.
00:14:4B	Hifn                   # Hifn, Inc.
00:14:4C	GeneralMet             # General Meters Corp.
00:14:4D	Intelligen             # Intelligent Systems
00:14:4E	Srisa
00:14:4F	SunMicrosy             # Sun Microsystems, Inc.
00:14:50	Heim                   # Heim Systems GmbH
00:14:51	AppleCompu             # Apple Computer Inc.
00:14:52	Calculex               # CALCULEX,INC.
00:14:53	AdvantechT             # ADVANTECH TECHNOLOGIES CO.,LTD
00:14:54	Symwave
00:14:55	CoderElect             # Coder Electronics Corporation
00:14:56	EdgeProduc             # Edge Products
00:14:57	T-VipsAs               # T-VIPS AS
00:14:58	HsAutomati             # HS Automatic ApS
00:14:59	Moram                  # Moram Co., Ltd.
00:14:5A	Elektrobit             # Elektrobit AG
00:14:5B	Seekernet              # SeekerNet Inc.
00:14:5C	IntronicsB             # Intronics B.V.
00:14:5D	WjCommunic             # WJ Communications, Inc.
00:14:5E	Ibm
00:14:5F	Aditec                 # ADITEC CO. LTD
00:14:60	KyoceraWir             # Kyocera Wireless Corp.
00:14:61	Corona                 # CORONA CORPORATION
00:14:62	DigiwellTe             # Digiwell Technology, inc
00:14:63	IdcsNV                 # IDCS N.V.
00:14:64	Cryptosoft
00:14:65	NovoNordis             # Novo Nordisk A/S
00:14:66	KleinhenzE             # Kleinhenz Elektronik GmbH
00:14:67	Arrowspan              # ArrowSpan Inc.
00:14:68	CelplanInt             # CelPlan International, Inc.
00:14:69	Cisco                  # Cisco Systems
00:14:6A	Cisco                  # Cisco Systems
00:14:6B	Anagran                # Anagran, Inc.
00:14:6C	Netgear                # Netgear Inc.
00:14:6D	RfTechnolo             # RF Technologies
00:14:6E	HStoll                 # H. Stoll GmbH & Co. KG
00:14:6F	Kohler                 # Kohler Co
00:14:70	ProkomSoft             # Prokom Software SA
00:14:71	EasternAsi             # Eastern Asia Technology Limited
00:14:72	ChinaBroad             # China Broadband Wireless IP Standard Group
00:14:73	Bookham                # Bookham Inc
00:14:74	K40Electro             # K40 Electronics
00:14:75	WilineNetw             # Wiline Networks, Inc.
00:14:76	MulticomIn             # MultiCom Industries Limited
00:14:77	Nertec                 # Nertec  Inc.
00:14:78	ShenzhenTp             # ShenZhen TP-LINK Technologies Co., Ltd.
00:14:79	NecMagnusC             # NEC Magnus Communications,Ltd.
00:14:7A	Eubus                  # Eubus GmbH
00:14:7B	Iteris                 # Iteris, Inc.
00:14:7C	3comEurope             # 3Com Europe Ltd
00:14:7D	AeonDigita             # Aeon Digital International
00:14:7E	PangoNetwo             # PanGo Networks, Inc.
00:14:7F	ThomsonTel             # Thomson Telecom Belgium
00:14:80	Hitachi-Lg             # Hitachi-LG Data Storage Korea, Inc
00:14:81	Multilink              # Multilink Inc
00:14:82	Gobacktv               # GoBackTV, Inc
00:14:83	Exs                    # eXS Inc.
00:14:84	CermateTec             # CERMATE TECHNOLOGIES INC
00:14:85	Giga-Byte
00:14:86	EchoDigita             # Echo Digital Audio Corporation
00:14:87	AmericanTe             # American Technology Integrators
00:14:88	AkorriNetw             # Akorri Networks
00:14:89	B15402100-             # B15402100 - JANDEI, S.L.
00:14:8A	ElinEbgTra             # Elin Ebg Traction Gmbh
00:14:8B	GloboElect             # Globo Electronic GmbH & Co. KG
00:14:8C	FortressTe             # Fortress Technologies
00:14:8D	CubicDefen             # Cubic Defense Simulation Systems
00:14:8E	TelePower              # Tele Power Inc.
00:14:8F	ProtronicF             # Protronic (Far East) Ltd.
00:14:90	Asp                    # ASP Corporation
00:14:91	DanielsEle             # Daniels Electronics Ltd.
00:14:92	LiteonMobi             # Liteon, Mobile Media Solution SBU
00:14:93	SystimaxSo             # Systimax Solutions
00:14:94	Esu                    # ESU AG
00:14:95	2wire                  # 2Wire, Inc.
00:14:96	Phonic                 # Phonic Corp.
00:14:97	ZhiyuanEle             # ZHIYUAN Eletronics co.,ltd.
00:14:98	VikingDesi             # Viking Design Technology
00:14:99	Helicomm               # Helicomm Inc
00:14:9A	MotorolaMo             # Motorola Mobile Devices Business
00:14:9B	NokotaComm             # Nokota Communications, LLC
00:14:9C	Hf                     # HF Company
00:14:9D	SoundId                # Sound ID Inc.
00:14:9E	Ubone                  # UbONE Co., Ltd
00:14:9F	SystemAndC             # System and Chips, Inc.
00:14:A0	RfidAssetT             # RFID Asset Track, Inc.
00:14:A1	Synchronou             # Synchronous Communication Corp
00:14:A2	CoreMicro              # Core Micro Systems Inc.
00:14:A3	VitelecBv              # Vitelec BV
00:14:A4	HonHaiPrec             # Hon Hai Precision Ind. Co., Ltd.
00:14:A5	GemtekTech             # Gemtek Technology Co., Ltd.
00:14:A6	Teranetics             # Teranetics, Inc.
00:14:A7	NokiaDanma             # Nokia Danmark A/S
00:14:A8	Cisco                  # Cisco Systems
00:14:A9	Cisco                  # Cisco Systems
00:14:AA	AshlyAudio             # Ashly Audio, Inc.
00:14:AB	SenhaiElec             # Senhai Electronic Technology Co., Ltd.
00:14:AC	BountifulW             # Bountiful WiFi
00:14:AD	GassnerWie             # Gassner Wiege- u. Me�technik GmbH
00:14:AE	Wizlogics              # Wizlogics Co., Ltd.
00:14:AF	Datasym                # Datasym Inc.
00:14:B0	NaeilCommu             # Naeil Community
00:14:B1	Avitec                 # Avitec AB
00:14:B2	Mcubelogic             # mCubelogics Corporation
00:14:B3	CorestarIn             # CoreStar International Corp
00:14:B4	GeneralDyn             # General Dynamics United Kingdom Ltd
00:14:B5	Private
00:14:B6	EnswerTech             # Enswer Technology Inc.
00:14:B7	ArInfotek              # AR Infotek Inc.
00:14:B8	Hill-Rom
00:14:B9	Stepmind
00:14:BA	CarversSaD             # Carvers SA de CV
00:14:BB	OpenInterf             # Open Interface North America
00:14:BC	SynecticTe             # SYNECTIC TELECOM EXPORTS PVT. LTD.
00:14:BD	Incnetwork             # incNETWORKS, Inc
00:14:BE	WinkCommun             # Wink communication technology CO.LTD
00:14:BF	Cisco-Link             # Cisco-Linksys LLC
00:14:C0	SymstreamT             # Symstream Technology Group Ltd
00:14:C1	USRobotics             # U.S. Robotics Corporation
00:14:C2	HewlettPac             # Hewlett Packard
00:14:C3	SeagateTec             # Seagate Technology LLC
00:14:C4	VitelcomMo             # Vitelcom Mobile Technology
00:14:C5	AliveTechn             # Alive Technologies Pty Ltd
00:14:C6	Quixant                # Quixant Ltd
00:14:C7	Nortel
00:14:C8	Contempora             # Contemporary Research Corp
00:14:C9	Silverback             # Silverback Systems, Inc.
00:14:CA	KeyRadio               # Key Radio Systems Limited
00:14:CB	Gmp|Wirele             # GMP|Wireless Medicine,Inc.
00:14:CC	Zetec                  # Zetec, Inc.
00:14:CD	Digitalzon             # DigitalZone Co., Ltd.
00:14:CE	Nf                     # NF CORPORATION
00:14:CF	NextlinkTo             # Nextlink.to A/S
00:14:D0	BtiPhotoni             # BTI Photonics
00:14:D1	TrendwareI             # TRENDware International, Inc.
00:14:D2	Kyuki                  # KYUKI CORPORATION
00:14:D3	Sepsa
00:14:D4	KTechnolog             # K Technology Corporation
00:14:D5	DatangTele             # Datang Telecom Technology CO. , LCD,Optical Communication Br
00:14:D6	JeongminEl             # Jeongmin Electronics Co.,Ltd.
00:14:D7	DatastorTe             # DataStor Technology Inc.
00:14:D8	Bio-LogicS             # bio-logic SA
00:14:D9	IpFabrics              # IP Fabrics, Inc.
00:14:DA	Sonicaid
00:14:DB	ElmaTrenew             # Elma Trenew Electronic GmbH
00:14:DC	Communicat             # Communication System Design & Manufacturing (CSDM)
00:14:DD	Covergence             # Covergence Inc.
00:14:DE	SageInstru             # Sage Instruments Inc.
00:14:DF	Hi-PTech               # HI-P Tech Corporation
00:14:E0	LetS                   # LET'S Corporation
00:14:E1	DataDispla             # Data Display AG
00:14:E2	Datacom                # datacom systems inc.
00:14:E3	Mm-Lab                 # mm-lab GmbH
00:14:E4	IntegralTe             # Integral Technologies
00:14:E5	Alticast
00:14:E6	AimInfraro             # AIM Infrarotmodule GmbH
00:14:E7	Stolinx                # Stolinx,. Inc
00:14:E8	MotorolaCh             # Motorola CHS
00:14:E9	NortechInt             # Nortech International
00:14:EA	SDigmSafeP             # S Digm Inc. (Safe Paradigm Inc.)
00:14:EB	Awarepoint             # AwarePoint Corporation
00:14:EC	AcroTeleco             # Acro Telecom
00:14:ED	Airak                  # Airak, Inc.
00:14:EE	WesternDig             # Western Digital Technologies, Inc.
00:14:EF	TzeroTechn             # TZero Technologies, Inc.
00:14:F0	BusinessSe             # Business Security OL AB
00:14:F1	Cisco                  # Cisco Systems
00:14:F2	Cisco                  # Cisco Systems
00:14:F3	Vixs                   # ViXS Systems Inc
00:14:F4	DektecDigi             # DekTec Digital Video B.V.
00:14:F5	OsiSecurit             # OSI Security Devices
00:14:F6	JuniperNet             # Juniper Networks, Inc.
00:14:F7	Crevis
00:14:F8	Scientific             # Scientific Atlanta
00:14:F9	VantageCon             # Vantage Controls
00:14:FA	AsgaSA                 # AsGa S.A.
00:14:FB	TechnicalS             # Technical Solutions Inc.
00:14:FC	Extandon               # Extandon, Inc.
00:14:FD	ThecusTech             # Thecus Technology Corp.
00:14:FE	ArtechElec             # Artech Electronics
00:14:FF	PreciseAut             # Precise Automation, LLC
00:15:00	IntelCorpo             # Intel Corporate
00:15:01	Lexbox
00:15:02	BetaTech               # BETA tech
00:15:03	Proficomms             # PROFIcomms s.r.o.
00:15:04	GamePlus               # GAME PLUS CO., LTD.
00:15:05	ActiontecE             # Actiontec Electronics, Inc
00:15:06	Beamexpres             # BeamExpress, Inc
00:15:07	Renaissanc             # Renaissance Learning Inc
00:15:08	GlobalTarg             # Global Target Enterprise Inc
00:15:09	PlusTechno             # Plus Technology Co., Ltd
00:15:0A	Sonoa                  # Sonoa Systems, Inc
00:15:0B	SageInfote             # SAGE INFOTECH LTD.
00:15:0C	Avm                    # AVM GmbH
00:15:0D	HoanaMedic             # Hoana Medical, Inc.
00:15:0E	OpenbrainT             # OPENBRAIN TECHNOLOGIES CO., LTD.
00:15:0F	Mingjong
00:15:10	Techsphere             # Techsphere Co., Ltd
00:15:11	DataCenter             # Data Center Systems
00:15:12	ZurichUniv             # Zurich University of Applied Sciences
00:15:13	EfsSas                 # EFS sas
00:15:14	HuZhouNava             # Hu Zhou NAVA Networks&Electronics Ltd.
00:15:15	Leipold+Co             # Leipold+Co.GmbH
00:15:16	Uriel                  # URIEL SYSTEMS INC.
00:15:17	IntelCorpo             # Intel Corporate
00:15:18	Shenzhen10             # Shenzhen 10MOONS Technology Development CO.,Ltd
00:15:19	StoreageNe             # StoreAge Networking Technologies
00:15:1A	HunterEngi             # Hunter Engineering Company
00:15:1B	Isilon                 # Isilon Systems Inc.
00:15:1C	Leneco
00:15:1D	M2i                    # M2I CORPORATION
00:15:1E	Metaware               # Metaware Co., Ltd.
00:15:1F	Multivisio             # Multivision Intelligent Surveillance (Hong Kong) Ltd
00:15:20	Radiocraft             # Radiocrafts AS
00:15:21	Horoquartz
00:15:22	DeaSecurit             # Dea Security
00:15:23	MeteorComm             # Meteor Communications Corporation
00:15:24	Numatics               # Numatics, Inc.
00:15:25	PtiIntegra             # PTI Integrated Systems, Inc.
00:15:26	RemoteTech             # Remote Technologies Inc
00:15:27	BalboaInst             # Balboa Instruments
00:15:28	BeaconMedi             # Beacon Medical Products LLC d.b.a. BeaconMedaes
00:15:29	N3                     # N3 Corporation
00:15:2A	Nokia                  # Nokia GmbH
00:15:2B	Cisco                  # Cisco Systems
00:15:2C	Cisco                  # Cisco Systems
00:15:2D	TenxNetwor             # TenX Networks, LLC
00:15:2E	Packethop              # PacketHop, Inc.
00:15:2F	MotorolaCh             # Motorola CHS
00:15:30	Bus-Tech               # Bus-Tech, Inc.
00:15:31	Kocom
00:15:32	ConsumerTe             # Consumer Technologies Group, LLC
00:15:33	Nadam                  # NADAM.CO.,LTD
00:15:34	ABeltr�Nic             # A BELTR�NICA, Companhia de Comunica��es, Lda
00:15:35	OteSpa                 # OTE Spa
00:15:36	Powertech              # Powertech co.,Ltd
00:15:37	VentusNetw             # Ventus Networks
00:15:38	Rfid                   # RFID, Inc.
00:15:39	Technodriv             # Technodrive SRL
00:15:3A	ShenzhenSy             # Shenzhen Syscan Technology Co.,Ltd.
00:15:3B	EmhElektri             # EMH Elektrizit�tsz�hler GmbH & CoKG
00:15:3C	Kprotech               # Kprotech Co., Ltd.
00:15:3D	ElimProduc             # ELIM PRODUCT CO.
00:15:3E	Q-MaticSwe             # Q-Matic Sweden AB
00:15:3F	AleniaSpaz             # Alenia Spazio S.p.A.
00:15:40	Nortel
00:15:41	Strataligh             # StrataLight Communications, Inc.
00:15:42	MicrohardS             # MICROHARD S.R.L.
00:15:43	AberdeenTe             # Aberdeen Test Center
00:15:44	ComSAT                 # coM.s.a.t. AG
00:15:45	Seecode                # SEECODE Co., Ltd.
00:15:46	ItgWorldwi             # ITG Worldwide Sdn Bhd
00:15:47	AizenSolut             # AiZen Solutions Inc.
00:15:48	CubeTechno             # CUBE TECHNOLOGIES
00:15:49	DixtalBiom             # Dixtal Biomedica Ind. Com. Ltda
00:15:4A	WanshihEle             # WANSHIH ELECTRONIC CO., LTD
00:15:4B	WondeProud             # Wonde Proud Technology Co., Ltd
00:15:4C	SaundersEl             # Saunders Electronics
00:15:4D	Netronome              # Netronome Systems, Inc.
00:15:4E	Hirschmann             # Hirschmann Automation and Control GmbH
00:15:4F	OneRfTechn             # one RF Technology
00:15:50	NitsTechno             # Nits Technology Inc
00:15:51	Radiopulse             # RadioPulse Inc.
00:15:52	Wi-Gear                # Wi-Gear Inc.
00:15:53	Cytyc                  # Cytyc Corporation
00:15:54	AtalumWire             # Atalum Wireless S.A.
00:15:55	Dfm                    # DFM GmbH
00:15:56	SagemSa                # SAGEM SA
00:15:57	Olivetti
00:15:58	Foxconn
00:15:59	Securaplan             # Securaplane Technologies, Inc.
00:15:5A	DainipponP             # DAINIPPON PHARMACEUTICAL CO., LTD.
00:15:5B	Sampo                  # Sampo Corporation
00:15:5C	DresserWay             # Dresser Wayne
00:15:5D	Microsoft              # Microsoft Corporation
00:15:5E	MorganStan             # Morgan Stanley
00:15:5F	Ubiwave
00:15:60	HewlettPac             # Hewlett Packard
00:15:61	Jjplus                 # JJPlus Corporation
00:15:62	Cisco                  # Cisco Systems
00:15:63	Cisco                  # Cisco Systems
00:15:64	BehringerS             # BEHRINGER Spezielle Studiotechnik GmbH
00:15:65	XiamenYeal             # XIAMEN YEALINK NETWORK TECHNOLOGY CO.,LTD
00:15:66	A-FirstTec             # A-First Technology Co., Ltd.
00:15:67	Radwin                 # RADWIN Inc.
00:15:68	DilithiumN             # Dilithium Networks
00:15:69	PecoIi                 # PECO II, Inc.
00:15:6A	Dg2lTechno             # DG2L Technologies Pvt. Ltd.
00:15:6B	PerfisansN             # Perfisans Networks Corp.
00:15:6C	SaneSystem             # SANE SYSTEM CO., LTD
00:15:6D	UbiquitiNe             # Ubiquiti Networks
00:15:6E	AWCommunic             # A. W. Communication Systems Ltd
00:15:6F	XiranetCom             # Xiranet Communications GmbH
00:15:70	SymbolTech             # Symbol Technologies
00:15:71	Nolan                  # Nolan Systems
00:15:72	Red-Lemon
00:15:73	NewsoftTec             # NewSoft  Technology Corporation
00:15:74	HorizonSem             # Horizon Semiconductors Ltd.
00:15:75	NevisNetwo             # Nevis Networks Inc.
00:15:76	ScilAnimal             # scil animal care company GmbH
00:15:77	AlliedTele             # Allied Telesyn, Inc.
00:15:78	Audio/Vide             # Audio / Video Innovations
00:15:79	LunatoneIn             # Lunatone Industrielle Elektronik GmbH
00:15:7A	TelefinSPA             # Telefin S.p.A.
00:15:7B	LeuzeElect             # Leuze electronic GmbH + Co. KG
00:15:7C	DaveNetwor             # Dave Networks, Inc.
00:15:7D	Posdata                # POSDATA CO., LTD.
00:15:7E	HeyfraElec             # HEYFRA ELECTRONIC gmbH
00:15:7F	ChuangInte             # ChuanG International Holding CO.,LTD.
00:15:80	U-Way                  # U-WAY CORPORATION
00:15:81	Makus                  # MAKUS Inc.
00:15:82	Tvonics                # TVonics Ltd
00:15:83	Ivt                    # IVT corporation
00:15:84	SchenckPro             # Schenck Process GmbH
00:15:85	AonvisionT             # Aonvision Technolopy Corp.
00:15:86	XiamenOver             # Xiamen Overseas Chinese Electronic Co., Ltd.
00:15:87	TakenakaSe             # Takenaka Seisakusho Co.,Ltd
00:15:88	Balda-Thon             # Balda-Thong Fook Solutions Sdn. Bhd.
00:15:89	D-MaxTechn             # D-MAX Technology Co.,Ltd
00:15:8A	SurecomTec             # SURECOM Technology Corp.
00:15:8B	ParkAir                # Park Air Systems Ltd
00:15:8C	LiabAps                # Liab ApS
00:15:8D	Jennic                 # Jennic Ltd
00:15:8E	Plustek                # Plustek.INC
00:15:8F	NttAdvance             # NTT Advanced Technology Corporation
00:15:90	Hectronic              # Hectronic GmbH
00:15:91	Rlw                    # RLW Inc.
00:15:92	FacomUkMel             # Facom UK Ltd (Melksham)
00:15:93	U4eaTechno             # U4EA Technologies Inc.
00:15:94	Bixolon                # BIXOLON CO.,LTD
00:15:95	QuesterTan             # Quester Tangent Corporation
00:15:96	ArrisInter             # ARRIS International
00:15:97	AetaAudio              # AETA AUDIO SYSTEMS
00:15:98	KolektorGr             # Kolektor group
00:15:99	SamsungEle             # Samsung Electronics Co., LTD
00:15:9A	MotorolaCh             # Motorola CHS
00:15:9B	Nortel
00:15:9C	B-KyungSys             # B-KYUNG SYSTEM Co.,Ltd.
00:15:9D	MinicomAdv             # Minicom Advanced Systems ltd
00:15:9E	Saitek                 # Saitek plc
00:15:9F	Terascala              # Terascala, Inc.
00:15:A0	NokiaDanma             # Nokia Danmark A/S
00:15:A1	SintersSas             # SINTERS SAS
00:15:A2	ArrisInter             # ARRIS International
00:15:A3	ArrisInter             # ARRIS International
00:15:A4	ArrisInter             # ARRIS International
00:15:A5	Dci                    # DCI Co., Ltd.
00:15:A6	DigitalEle             # Digital Electronics Products Ltd.
00:15:A7	Robatech               # Robatech AG
00:15:A8	MotorolaMo             # Motorola Mobile Devices
00:15:A9	KwangWooI&             # KWANG WOO I&C CO.,LTD
00:15:AA	Rextechnik             # Rextechnik International Co.,
00:15:AB	ProSound               # PRO CO SOUND INC
00:15:AC	Capelon                # Capelon AB
00:15:AD	AccedianNe             # Accedian Networks
00:15:AE	KyungIl                # kyung il
00:15:AF	AzurewaveT             # AzureWave Technologies, Inc.
00:15:B0	Autotelene             # AUTOTELENET CO.,LTD
00:15:B1	Ambient                # Ambient Corporation
00:15:B2	AdvancedIn             # Advanced Industrial Computer, Inc.
00:15:B3	Caretech               # Caretech AB
00:15:B4	PolymapWir             # Polymap  Wireless LLC
00:15:B5	CiNetwork              # CI Network Corp.
00:15:B6	ShinmaywaI             # ShinMaywa Industries, Ltd.
00:15:B7	Toshiba
00:15:B8	Tahoe
00:15:B9	SamsungEle             # Samsung Electronics Co., Ltd.
00:15:BA	Iba                    # iba AG
00:15:BB	SmaTechnol             # SMA Technologie AG
00:15:BC	Develco
00:15:BD	Group4Tech             # Group 4 Technology Ltd
00:15:BE	Iqua                   # Iqua Ltd.
00:15:BF	Technicob
00:15:C0	DigitalTel             # DIGITAL TELEMEDIA CO.,LTD.
00:15:C1	SonyComput             # SONY Computer Entertainment inc,
00:15:C2	3mGermany              # 3M Germany
00:15:C3	RufTelemat             # Ruf Telematik AG
00:15:C4	Flovel                 # FLOVEL CO., LTD.
00:15:C5	Dell                   # Dell Inc
00:15:C6	Cisco                  # Cisco Systems
00:15:C7	Cisco                  # Cisco Systems
00:15:C8	Flexipanel             # FlexiPanel Ltd
00:15:C9	Gumstix                # Gumstix, Inc
00:15:CA	Terarecon              # TeraRecon, Inc.
00:15:CB	SurfCommun             # Surf Communication Solutions Ltd.
00:15:CC	TepcoUques             # TEPCO UQUEST, LTD.
00:15:CD	ExartechIn             # Exartech International Corp.
00:15:CE	ArrisInter             # ARRIS International
00:15:CF	ArrisInter             # ARRIS International
00:15:D0	ArrisInter             # ARRIS International
00:15:D1	ArrisInter             # ARRIS International
00:15:D2	Xantech                # Xantech Corporation
00:15:D3	Pantech&Cu             # Pantech&Curitel Communications, Inc.
00:15:D4	Emitor                 # Emitor AB
00:15:D5	Nicevt
00:15:D6	OslinkSpZO             # OSLiNK Sp. z o.o.
00:15:D7	Reti                   # Reti Corporation
00:15:D8	InterlinkE             # Interlink Electronics
00:15:D9	PkcElectro             # PKC Electronics Oy
00:15:DA	IritelAD               # IRITEL A.D.
00:15:DB	Canesta                # Canesta Inc.
00:15:DC	Kt&C                   # KT&C Co., Ltd.
00:15:DD	IpControl              # IP Control Systems Ltd.
00:15:DE	NokiaDanma             # Nokia Danmark A/S
00:15:DF	ClivetSPA              # Clivet S.p.A.
00:15:E0	EricssonMo             # Ericsson Mobile Platforms
00:15:E1	PicochipDe             # picoChip Designs Ltd
00:15:E2	Wissenscha             # Wissenschaftliche Geraetebau Dr. Ing. H. Knauer GmbH
00:15:E3	DreamTechn             # Dream Technologies Corporation
00:15:E4	ZimmerElek             # Zimmer Elektromedizin
00:15:E5	Cheertek               # Cheertek Inc.
00:15:E6	MobileTech             # MOBILE TECHNIKA Inc.
00:15:E7	QuantecPro             # Quantec ProAudio
00:15:E8	Nortel
00:15:E9	D-Link                 # D-Link Corporation
00:15:EA	TellumatPt             # Tellumat (Pty) Ltd
00:15:EB	Zte                    # ZTE CORPORATION
00:15:EC	BocaDevice             # Boca Devices LLC
00:15:ED	FulcrumMic             # Fulcrum Microsystems, Inc.
00:15:EE	OmnexContr             # Omnex Control Systems
00:15:EF	NecTokin               # NEC TOKIN Corporation
00:15:F0	EgoBv                  # EGO BV
00:15:F1	KylinkComm             # KYLINK Communications Corp.
00:15:F2	AsustekCom             # ASUSTek COMPUTER INC.
00:15:F3	Peltor                 # PELTOR AB
00:15:F4	Eventide
00:15:F5	Sustainabl             # Sustainable Energy Systems
00:15:F6	ScienceAnd             # SCIENCE AND ENGINEERING SERVICES, INC.
00:15:F7	Wintecroni             # Wintecronics Ltd.
00:15:F8	Kingtronic             # Kingtronics Industrial Co. Ltd.
00:15:F9	Cisco                  # Cisco Systems
00:15:FA	Cisco                  # Cisco Systems
00:15:FB	SetexScher             # setex schermuly textile computer gmbh
00:15:FC	StartcoEng             # Startco Engineering Ltd.
00:15:FD	CompleteMe             # Complete Media Systems
00:15:FE	SchillingR             # SCHILLING ROBOTICS LLC
00:15:FF	NovatelWir             # Novatel Wireless, Inc.
00:16:00	Cellebrite             # CelleBrite Mobile Synchronization
00:16:01	Buffalo                # Buffalo Inc.
00:16:02	CeyonTechn             # CEYON TECHNOLOGY CO.,LTD.
00:16:03	Private
00:16:04	Sigpro
00:16:05	YorkvilleS             # YORKVILLE SOUND INC.
00:16:06	IdealIndus             # Ideal Industries
00:16:07	CurvesInte             # Curves International Inc.
00:16:08	SequansCom             # Sequans Communications
00:16:09	UnitechEle             # Unitech electronics co., ltd.
00:16:0A	SweexEurop             # SWEEX Europe BV
00:16:0B	TvworksLlc             # TVWorks LLC
00:16:0C	LplDevelop             # LPL  DEVELOPMENT S.A. DE C.V
00:16:0D	BeHere                 # Be Here Corporation
00:16:0E	OpticaTech             # Optica Technologies Inc.
00:16:0F	BadgerMete             # BADGER METER INC
00:16:10	CarinaTech             # Carina Technology
00:16:11	AlteconSrl             # Altecon Srl
00:16:12	OtsukaElec             # Otsuka Electronics Co., Ltd.
00:16:13	Librestrea             # LibreStream Technologies Inc.
00:16:14	Picosecond             # Picosecond Pulse Labs
00:16:15	Nittan                 # Nittan Company, Limited
00:16:16	BrowanComm             # BROWAN COMMUNICATION INC.
00:16:17	Msi
00:16:18	Hivion                 # HIVION Co., Ltd.
00:16:19	LaFactor�A             # La Factor�a de Comunicaciones Aplicadas,S.L.
00:16:1A	Dametric               # Dametric AB
00:16:1B	Micronet               # Micronet Corporation
00:16:1C	E:Cue
00:16:1D	Innovative             # Innovative Wireless Technologies, Inc.
00:16:1E	Woojinnet
00:16:1F	Sunwavetec             # SUNWAVETEC Co., Ltd.
00:16:20	SonyEricss             # Sony Ericsson Mobile Communications AB
00:16:21	ColoradoVn             # Colorado Vnet
00:16:22	Bbh                    # BBH SYSTEMS GMBH
00:16:23	IntervalMe             # Interval Media
00:16:24	Private
00:16:25	Impinj                 # Impinj, Inc.
00:16:26	MotorolaCh             # Motorola CHS
00:16:27	Embedded-L             # embedded-logic DESIGN AND MORE GmbH
00:16:28	UltraElect             # Ultra Electronics Manufacturing and Card Systems
00:16:29	Nivus                  # Nivus GmbH
00:16:2A	AntikCompu             # Antik computers & communications s.r.o.
00:16:2B	TogamiElec             # Togami Electric Mfg.co.,Ltd.
00:16:2C	Xanboo
00:16:2D	Stnet                  # STNet Co., Ltd.
00:16:2E	SpaceShutt             # Space Shuttle Hi-Tech Co., Ltd.
00:16:2F	Geutebr�Ck             # Geutebr�ck GmbH
00:16:30	VativTechn             # Vativ Technologies
00:16:31	Xteam
00:16:32	SamsungEle             # SAMSUNG ELECTRONICS CO., LTD.
00:16:33	OxfordDiag             # Oxford Diagnostics Ltd.
00:16:34	Mathtech               # Mathtech, Inc.
00:16:35	HewlettPac             # Hewlett Packard
00:16:36	QuantaComp             # Quanta Computer Inc.
00:16:37	CitelSrl               # Citel Srl
00:16:38	Tecom                  # TECOM Co., Ltd.
00:16:39	Ubiquam                # UBIQUAM Co.,Ltd
00:16:3A	YvesTechno             # YVES TECHNOLOGY CO., LTD.
00:16:3B	Vertexrsi/             # VertexRSI/General Dynamics
00:16:3C	ReboxBV                # Rebox B.V.
00:16:3D	TsinghuaTo             # Tsinghua Tongfang Legend Silicon Tech. Co., Ltd.
00:16:3E	Xensource              # Xensource, Inc.
00:16:3F	Crete                  # CReTE SYSTEMS Inc.
00:16:40	AsmobileCo             # Asmobile Communication Inc.
00:16:41	Usi
00:16:42	Pangolin
00:16:43	SunhilloCo             # Sunhillo Corproation
00:16:44	Lite-OnTec             # LITE-ON Technology Corp.
00:16:45	PowerDistr             # Power Distribution, Inc.
00:16:46	Cisco                  # Cisco Systems
00:16:47	Cisco                  # Cisco Systems
00:16:48	Ssd                    # SSD Company Limited
00:16:49	Setone                 # SetOne GmbH
00:16:4A	VibrationT             # Vibration Technology Limited
00:16:4B	QuorionDat             # Quorion Data Systems GmbH
00:16:4C	PlanetInt              # PLANET INT Co., Ltd
00:16:4D	AlcatelNor             # Alcatel North America IP Division
00:16:4E	NokiaDanma             # Nokia Danmark A/S
00:16:4F	WorldEthni             # World Ethnic Broadcastin Inc.
00:16:50	EyalMicrow             # EYAL MICROWAVE
00:16:51	Private
00:16:52	HoatechTec             # Hoatech Technologies, Inc.
00:16:53	LegoSystem             # LEGO System A/S IE Electronics Division
00:16:54	Flex-PIndu             # Flex-P Industries Sdn. Bhd.
00:16:55	FuhoTechno             # FUHO TECHNOLOGY Co., LTD
00:16:56	Nintendo               # Nintendo Co., Ltd.
00:16:57	Aegate                 # Aegate Ltd
00:16:58	Fusiontech             # Fusiontech Technologies Inc.
00:16:59	ZMPRadwag              # Z.M.P. RADWAG
00:16:5A	HarmanSpec             # Harman Specialty Group
00:16:5B	GripAudio              # Grip Audio
00:16:5C	Trackflow              # Trackflow Ltd
00:16:5D	Airdefense             # AirDefense, Inc.
00:16:5E	PrecisionI             # Precision I/O
00:16:5F	FairmountA             # Fairmount Automation
00:16:60	Nortel
00:16:61	NovatiumSo             # Novatium Solutions (P) Ltd
00:16:62	LiyuhTechn             # Liyuh Technology Ltd.
00:16:63	KbtMobile              # KBT Mobile
00:16:64	Prod-ElSpa             # Prod-El SpA
00:16:65	CellonFran             # Cellon France
00:16:66	QuantierCo             # Quantier Communication Inc.
00:16:67	A-TecSubsy             # A-TEC Subsystem INC.
00:16:68	EishinElec             # Eishin Electronics
00:16:69	MrvCommuni             # MRV Communication (Networks) LTD
00:16:6A	Tps
00:16:6B	SamsungEle             # Samsung Electronics
00:16:6C	SamsungEle             # Samsung Electonics Digital Video System Division
00:16:6D	YulongComp             # Yulong Computer Telecommunication Scientific(shenzhen)Co.,Lt
00:16:6E	Arbitron               # Arbitron Inc.
00:16:6F	Intel                  # Intel Corporation
00:16:70	Sknet                  # SKNET Corporation
00:16:71	SymphoxInf             # Symphox Information Co.
00:16:72	ZenwayEnte             # Zenway enterprise ltd
00:16:73	Private
00:16:74	EurocbPhil             # EuroCB (Phils.), Inc.
00:16:75	MotorolaMd             # Motorola MDb
00:16:76	Intel                  # Intel Corporation
00:16:77	Bihl+Wiede             # Bihl+Wiedemann GmbH
00:16:78	ShenzhenBa             # SHENZHEN BAOAN GAOKE ELECTRONICS CO., LTD
00:16:79	EonCommuni             # eOn Communications
00:16:7A	SkyworthOv             # Skyworth Overseas Dvelopment Ltd.
00:16:7B	Haver&Boec             # Haver&Boecker
00:16:7C	IrexTechno             # iRex Technologies BV
00:16:7D	Sky-Line
00:16:7E	Diboss                 # DIBOSS.CO.,LTD
00:16:7F	BluebirdSo             # Bluebird Soft Inc.
00:16:80	BallyGamin             # Bally Gaming + Systems
00:16:81	VectorInfo             # Vector Informatik GmbH
00:16:82	ProDex                 # Pro Dex, Inc
00:16:83	WebioInter             # WEBIO International Co.,.Ltd.
00:16:84	Donjin                 # Donjin Co.,Ltd.
00:16:85	FrwdTechno             # FRWD Technologies Ltd.
00:16:86	KarlStorzI             # Karl Storz Imaging
00:16:87	ChubbCsc-V             # Chubb CSC-Vendor AP
00:16:88	Serverengi             # ServerEngines LLC
00:16:89	PilkorElec             # Pilkor Electronics Co., Ltd
00:16:8A	Id-Confirm             # id-Confirm Inc
00:16:8B	Paralan                # Paralan Corporation
00:16:8C	DslPartner             # DSL Partner AS
00:16:8D	Korwin                 # KORWIN CO., Ltd.
00:16:8E	Vimicro                # Vimicro corporation
00:16:8F	GnNetcomAs             # GN Netcom as
00:16:90	J-TekIncor             # J-TEK INCORPORATION
00:16:91	Moser-Baer             # Moser-Baer AG
00:16:92	Scientific             # Scientific-Atlanta, Inc.
00:16:93	PowerlinkT             # PowerLink Technology Inc.
00:16:94	Sennheiser             # Sennheiser Communications A/S
00:16:95	AvcTechnol             # AVC Technology Limited
00:16:96	QdiTechnol             # QDI Technology (H.K.) Limited
00:16:97	Nec                    # NEC Corporation
00:16:98	T&AMobileP             # T&A Mobile Phones SAS
00:16:99	Private
00:16:9A	Quadrics               # Quadrics Ltd
00:16:9B	AlstomTran             # Alstom Transport
00:16:9C	Cisco                  # Cisco Systems
00:16:9D	Cisco                  # Cisco Systems
00:16:9E	TvOne                  # TV One Ltd
00:16:9F	VimtronEle             # Vimtron Electronics Co., Ltd.
00:16:A0	Auto-Maski             # Auto-Maskin
00:16:A1	3leafNetwo             # 3Leaf Networks
00:16:A2	Centralite             # CentraLite Systems, Inc.
00:16:A3	TeamArtech             # TEAM ARTECHE, S.A.
00:16:A4	Ezurio                 # Ezurio Ltd
00:16:A5	TandbergSt             # Tandberg Storage ASA
00:16:A6	DovadoFz-L             # Dovado FZ-LLC
00:16:A7	AwetaG&P               # AWETA G&P
00:16:A8	Cwt                    # CWT CO., LTD.
00:16:A9	2ei
00:16:AA	KeiCommuni             # Kei Communication Technology Inc.
00:16:AB	Pbi-Dansen             # PBI-Dansensor A/S
00:16:AC	TohoTechno             # Toho Technology Corp.
00:16:AD	Bt-Links               # BT-Links Company Limited
00:16:AE	Inventel
00:16:AF	ShenzhenUn             # Shenzhen Union Networks Equipment Co.,Ltd.
00:16:B0	Vk                     # VK Corporation
00:16:B1	Kbs
00:16:B2	Drivecam               # DriveCam Inc
00:16:B3	Photonicbr             # Photonicbridges (China) Co., Ltd.
00:16:B4	Private
00:16:B5	MotorolaCh             # Motorola CHS
00:16:B6	Cisco-Link             # Cisco-Linksys
00:16:B7	SeoulCommt             # Seoul Commtech
00:16:B8	SonyEricss             # Sony Ericsson Mobile Communications
00:16:B9	ProcurveNe             # ProCurve Networking
00:16:BA	Weathernew             # WEATHERNEWS INC.
00:16:BB	Law-ChainC             # Law-Chain Computer Technology Co Ltd
00:16:BC	NokiaDanma             # Nokia Danmark A/S
00:16:BD	AtiIndustr             # ATI Industrial Automation
00:16:BE	Infranet               # INFRANET, Inc.
00:16:BF	PalodexGro             # PaloDEx Group Oy
00:16:C0	Semtech                # Semtech Corporation
00:16:C1	Eleksen                # Eleksen Ltd
00:16:C2	Avtec                  # Avtec Systems Inc
00:16:C3	Ba                     # BA Systems Inc
00:16:C4	SirfTechno             # SiRF Technology, Inc.
00:16:C5	ShenzhenXi             # Shenzhen Xing Feng Industry Co.,Ltd
00:16:C6	NorthAtlan             # North Atlantic Industries
00:16:C7	Cisco                  # Cisco Systems
00:16:C8	Cisco                  # Cisco Systems
00:16:C9	NatSeattle             # NAT Seattle, Inc.
00:16:CA	Nortel
00:16:CB	AppleCompu             # Apple Computer
00:16:CC	XcuteMobil             # Xcute Mobile Corp.
00:16:CD	HijiHigh-T             # HIJI HIGH-TECH CO., LTD.
00:16:CE	HonHaiPrec             # Hon Hai Precision Ind. Co., Ltd.
00:16:CF	HonHaiPrec             # Hon Hai Precision Ind. Co., Ltd.
00:16:D0	AtechElekt             # ATech elektronika d.o.o.
00:16:D1	ZatAS                  # ZAT a.s.
00:16:D2	Caspian
00:16:D3	Wistron                # Wistron Corporation
00:16:D4	CompalComm             # Compal Communications, Inc.
00:16:D5	Synccom                # Synccom Co., Ltd
00:16:D6	TdaTechPty             # TDA Tech Pty Ltd
00:16:D7	Sunways                # Sunways AG
00:16:D8	Senea                  # Senea AB
00:16:D9	NingboBird             # NINGBO BIRD CO.,LTD.
00:16:DA	FutronicTe             # Futronic Technology Co. Ltd.
00:16:DB	SamsungEle             # Samsung Electronics Co., Ltd.
00:16:DC	Archos
00:16:DD	Gigabeam               # Gigabeam Corporation
00:16:DE	Fast                   # FAST Inc
00:16:DF	Lundinova              # Lundinova AB
00:16:E0	3comEurope             # 3Com Europe Ltd
00:16:E1	Siliconsto             # SiliconStor, Inc.
00:16:E2	AmericanFi             # American Fibertek, Inc.
00:16:E3	AskeyCompu             # ASKEY COMPUTER CORP.
00:16:E4	VanguardSe             # VANGUARD SECURITY ENGINEERING CORP.
00:16:E5	FordleyDev             # FORDLEY DEVELOPMENT LIMITED
00:16:E6	Giga-ByteT             # GIGA-BYTE TECHNOLOGY CO.,LTD.
00:16:E7	DynamixPro             # Dynamix Promotions Limited
00:16:E8	SigmaDesig             # Sigma Designs, Inc.
00:16:E9	TibaMedica             # Tiba Medical Inc
00:16:EA	Intel                  # Intel Corporation
00:16:EB	Intel                  # Intel Corporation
00:16:EC	Elitegroup             # Elitegroup Computer Systems Co., Ltd.
00:16:ED	Integrian              # Integrian, Inc.
00:16:EE	Royaldigit             # RoyalDigital Inc.
00:16:EF	KokoFitnes             # Koko Fitness, Inc.
00:16:F0	Zermatt                # Zermatt Systems, Inc
00:16:F1	OmnisenseL             # OmniSense, LLC
00:16:F2	DmobileSys             # Dmobile System Co., Ltd.
00:16:F3	CastInform             # CAST Information Co., Ltd
00:16:F4	Eidicom                # Eidicom Co., Ltd.
00:16:F5	DalianGold             # Dalian Golden Hualu Digital Technology Co.,Ltd
00:16:F6	VideoProdu             # Video Products Group
00:16:F7	L-3Communi             # L-3 Communications, Electrodynamics, Inc.
00:16:F8	Private
00:16:F9	CetrtaPotD             # CETRTA POT, d.o.o., Kranj
00:16:FA	EciTelecom             # ECI Telecom Ltd.
00:16:FB	ShenzhenMt             # SHENZHEN MTC CO.,LTD.
00:16:FC	Tohken                 # TOHKEN CO.,LTD.
00:16:FD	JatyElectr             # Jaty Electronics
00:16:FE	AlpsElectr             # Alps Electric Co., Ltd
00:16:FF	WaminOptoc             # Wamin Optocomm Mfg Corp
00:17:00	MotorolaMd             # Motorola MDb
00:17:01	Kde                    # KDE, Inc.
00:17:02	OsungMidic             # Osung Midicom Co., Ltd
00:17:03	MosdanInte             # MOSDAN Internation Co.,Ltd
00:17:04	ShincoElec             # Shinco Electronics Group Co.,Ltd
00:17:05	MethodeEle             # Methode Electronics
00:17:06	Techfaithw             # Techfaithwireless Communication Technology Limited.
00:17:07	Ingrid                 # InGrid, Inc
00:17:08	HewlettPac             # Hewlett Packard
00:17:09	ExaltCommu             # Exalt Communications
00:17:0A	InewDigita             # INEW DIGITAL COMPANY
00:17:0B	Contela                # Contela, Inc.
00:17:0C	BenefonOyj             # Benefon Oyj
00:17:0D	DustNetwor             # Dust Networks Inc.
00:17:0E	Cisco                  # Cisco Systems
00:17:0F	Cisco                  # Cisco Systems
00:17:10	Casa                   # Casa Systems Inc.
00:17:11	GeHealthca             # GE Healthcare Bio-Sciences AB
00:17:12	IscoIntern             # ISCO International
00:17:13	TigerNetco             # Tiger NetCom
00:17:14	BrControls             # BR Controls Nederland bv
00:17:15	Qstik
00:17:16	QnoTechnol             # Qno Technology Inc.
00:17:17	LeicaGeosy             # Leica Geosystems AG
00:17:18	VanscoElec             # Vansco Electronics Oy
00:17:19	Audiocodes             # AudioCodes USA, Inc
00:17:1A	Winegard               # Winegard Company
00:17:1B	Innovation             # Innovation Lab Corp.
00:17:1C	NtMicrosys             # NT MicroSystems, Inc.
00:17:1D	Digit
00:17:1E	TheoBennin             # Theo Benning GmbH & Co. KG
00:17:1F	Imv                    # IMV Corporation
00:17:20	ImageSensi             # Image Sensing Systems, Inc.
00:17:21	FitreSPA               # FITRE S.p.A.
00:17:22	HanazederE             # Hanazeder Electronic GmbH
00:17:23	SummitData             # Summit Data Communications
00:17:24	StuderProf             # Studer Professional Audio GmbH
00:17:25	LiquidComp             # Liquid Computing
00:17:26	M2cElectro             # m2c Electronic Technology Ltd.
00:17:27	ThermoRams             # Thermo Ramsey Italia s.r.l.
00:17:28	SelexCommu             # Selex Communications
00:17:29	Ubicod                 # Ubicod Co.LTD
00:17:2A	ProwareTec             # Proware Technology Corp.
00:17:2B	GlobalTech             # Global Technologies Inc.
00:17:2C	TaejinInfo             # TAEJIN INFOTECH
00:17:2D	AxcenPhoto             # Axcen Photonics Corporation
00:17:2E	Fxc                    # FXC Inc.
00:17:2F	Neulion                # NeuLion Incorporated
00:17:30	Automation             # Automation Electronics
00:17:31	AsustekCom             # ASUSTek COMPUTER INC.
00:17:32	Science-Te             # Science-Technical Center "RISSA"
00:17:33	NeufCegete             # neuf cegetel
00:17:34	LgcWireles             # LGC Wireless Inc.
00:17:35	Private
00:17:36	Iitron                 # iiTron Inc.
00:17:37	IndustrieD             # Industrie Dial Face S.p.A.
00:17:38	Xiv
00:17:39	BrightHead             # Bright Headphone Electronics Company
00:17:3A	EdgeIntegr             # Edge Integration Systems Inc.
00:17:3B	ArchedRock             # Arched Rock Corporation
00:17:3C	ExtremeEng             # Extreme Engineering Solutions
00:17:3D	Neology
00:17:3E	Leucotrone             # LeucotronEquipamentos Ltda.
00:17:3F	Belkin                 # Belkin Corporation
00:17:40	Technologi             # Technologies Labtronix
00:17:41	Defidev
00:17:42	Fujitsu                # FUJITSU LIMITED
00:17:43	Private
00:17:44	Araneo                 # Araneo Ltd.
00:17:45	Innotz                 # INNOTZ CO., Ltd
00:17:46	Freedom9               # Freedom9 Inc.
00:17:47	Trimble
00:17:48	NeokorosBr             # Neokoros Brasil Ltda
00:17:49	HyundaeYon             # HYUNDAE YONG-O-SA CO.,LTD
00:17:4A	Socomec
00:17:4B	NokiaDanma             # Nokia Danmark A/S
00:17:4C	Millipore
00:17:4D	DynamicNet             # DYNAMIC NETWORK FACTORY, INC.
00:17:4E	Parama-Tec             # Parama-tech Co.,Ltd.
00:17:4F	Icatch                 # iCatch Inc.
00:17:50	GsiGroupMi             # GSI Group, MicroE Systems
00:17:51	Online                 # Online Corporation
00:17:52	Dags                   # DAGS, Inc
00:17:53	NforeTechn             # nFore Technology Inc.
00:17:54	Arkino                 # Arkino Corporation., Ltd
00:17:55	GeSecurity             # GE Security
00:17:56	VinciLabsO             # Vinci Labs Oy
00:17:57	RixTechnol             # RIX TECHNOLOGY LIMITED
00:17:58	Thruvision             # ThruVision Ltd
00:17:59	Cisco                  # Cisco Systems
00:17:5A	Cisco                  # Cisco Systems
00:17:5B	AcsSolutio             # ACS Solutions Switzerland Ltd.
00:17:5C	Sharp                  # SHARP CORPORATION
00:17:5D	DongseoSys             # Dongseo system.
00:17:5E	Anta                   # Anta Systems, Inc.
00:17:5F	XenolinkCo             # XENOLINK Communications Co., Ltd.
00:17:60	NaitoDense             # Naito Densei Machida MFG.CO.,LTD
00:17:61	Zksoftware             # ZKSoftware Inc.
00:17:62	SolarTechn             # Solar Technology, Inc.
00:17:63	EssentiaSP             # Essentia S.p.A.
00:17:64	Atmedia                # ATMedia GmbH
00:17:65	Nortel
00:17:66	AccenseTec             # Accense Technology, Inc.
00:17:67	EarforceAs             # Earforce AS
00:17:68	Zinwave                # Zinwave Ltd
00:17:69	Cymphonix              # Cymphonix Corp
00:17:6A	AvagoTechn             # Avago Technologies
00:17:6B	Kiyon                  # Kiyon, Inc.
00:17:6C	Pivot3                 # Pivot3, Inc.
00:17:6D	Core                   # CORE CORPORATION
00:17:6E	DucatiSist             # DUCATI SISTEMI
00:17:6F	PaxCompute             # PAX Computer Technology(Shenzhen) Ltd.
00:17:70	ArtiIndust             # Arti Industrial Electronics Ltd.
00:17:71	ApdCommuni             # APD Communications Ltd
00:17:72	AstroStrob             # ASTRO Strobel Kommunikationssysteme GmbH
00:17:73	LaketuneTe             # Laketune Technologies Co. Ltd
00:17:74	Elesta                 # Elesta GmbH
00:17:75	TteGermany             # TTE Germany GmbH
00:17:76	MesoScaleD             # Meso Scale Diagnostics, LLC
00:17:77	ObsidianRe             # Obsidian Research Corporation
00:17:78	CentralMus             # Central Music Co.
00:17:79	Quicktel
00:17:7A	AssaAbloy              # ASSA ABLOY AB
00:17:7B	AzaleaNetw             # Azalea Networks inc
00:17:7C	D-LinkIndi             # D-Link India Ltd
00:17:7D	IdtInterna             # IDT International Limited
00:17:7E	MeshcomTec             # Meshcom Technologies Inc.
00:17:7F	Worldsmart             # Worldsmart Retech
00:17:80	AppleraHol             # Applera Holding B.V. Singapore Operations
00:17:81	GreystoneD             # Greystone Data System, Inc.
00:17:82	Lobenn                 # LoBenn Inc.
00:17:83	TexasInstr             # Texas Instruments
00:17:84	MotorolaMo             # Motorola Mobile Devices
00:17:85	SparrElect             # Sparr Electronics Ltd
00:17:86	Wisembed
00:17:87	BrotherBro             # Brother, Brother & Sons ApS
00:17:88	PhilipsLig             # Philips Lighting BV
00:17:89	Zenitron               # Zenitron Corporation
00:17:8A	DartsTechn             # DARTS TECHNOLOGIES CORP.
00:17:8B	TeledyneTe             # Teledyne Technologies Incorporated
00:17:8C	Independen             # Independent Witness, Inc
00:17:8D	Checkpoint             # Checkpoint Systems, Inc.
00:17:8E	GunneboCas             # Gunnebo Cash Automation AB
00:17:8F	NingboYido             # NINGBO YIDONG ELECTRONIC CO.,LTD.
00:17:90	HyundaiDig             # HYUNDAI DIGITECH Co, Ltd.
00:17:91	Lintech                # LinTech GmbH
00:17:92	FalcomWire             # Falcom Wireless Comunications Gmbh
00:17:93	Tigi                   # Tigi Corporation
00:17:94	Cisco                  # Cisco Systems
00:17:95	Cisco                  # Cisco Systems
00:17:96	Rittmeyer              # Rittmeyer AG
00:17:97	TelsyElett             # Telsy Elettronica S.p.A.
00:17:98	AzonicTech             # Azonic Technology Co., LTD
00:17:99	Smartire               # SmarTire Systems Inc.
00:17:9A	D-Link                 # D-Link Corporation
00:17:9B	ChantSince             # Chant Sincere CO., LTD.
00:17:9C	DepragSchu             # DEPRAG SCHULZ GMBH u. CO.
00:17:9D	Kelman                 # Kelman Limited
00:17:9E	Sirit                  # Sirit Inc
00:17:9F	Apricorn
00:17:A0	RobotechSr             # RoboTech srl
00:17:A1	3soft                  # 3soft inc.
00:17:A2	Camrivox               # Camrivox Ltd.
00:17:A3	MixSRL                 # MIX s.r.l.
00:17:A4	GlobalData             # Global Data Services
00:17:A5	TrendchipT             # TrendChip Technologies Corp.
00:17:A6	YosinElect             # YOSIN ELECTRONICS CO., LTD.
00:17:A7	MobileComp             # Mobile Computing Promotion Consortium
00:17:A8	Edm                    # EDM Corporation
00:17:A9	Sentivisio             # Sentivision
00:17:AA	Elab-Exper             # elab-experience inc.
00:17:AB	Nintendo               # Nintendo Co., Ltd.
00:17:AC	ONeilProdu             # O'Neil Product Development Inc.
00:17:AD	Acenet                 # AceNet Corporation
00:17:AE	Gai-Tronic             # GAI-Tronics
00:17:AF	Enermet
00:17:B0	NokiaDanma             # Nokia Danmark A/S
00:17:B1	AcistMedic             # ACIST Medical Systems, Inc.
00:17:B2	SkTelesys              # SK Telesys
00:17:B3	AftekInfos             # Aftek Infosys Limited
00:17:B4	RemoteSecu             # Remote Security Systems, LLC
00:17:B5	Peerless               # Peerless Systems Corporation
00:17:B6	Aquantia
00:17:B7	TonzeTechn             # Tonze Technology Co.
00:17:B8	Novatron               # NOVATRON CO., LTD.
00:17:B9	GambroLund             # Gambro Lundia AB
00:17:BA	Sedo                   # SEDO CO., LTD.
00:17:BB	SyrinxIndu             # Syrinx Industrial Electronics
00:17:BC	Touchtunes             # Touchtunes Music Corporation
00:17:BD	Tibetsyste             # Tibetsystem
00:17:BE	TratecTele             # Tratec Telecom B.V.
00:17:BF	CoherentRe             # Coherent Research Limited
00:17:C0	Puretech               # PureTech Systems, Inc.
00:17:C1	CmPrecisio             # CM Precision Technology LTD.
00:17:C2	PirelliBro             # Pirelli Broadband Solutions
00:17:C3	KtfTechnol             # KTF Technologies Inc.
00:17:C4	QuantaMicr             # Quanta Microsystems, INC.
00:17:C5	Sonicwall
00:17:C6	LabcalTech             # Labcal Technologies
00:17:C7	MaraConsul             # MARA Systems Consulting AB
00:17:C8	KyoceraMit             # Kyocera Mita Corporation
00:17:C9	SamsungEle             # Samsung Electronics Co., Ltd.
00:17:CA	Benq                   # BenQ Corporation
00:17:CB	JuniperNet             # Juniper Networks
00:17:CC	AlcatelUsa             # Alcatel USA Sourcing LP
00:17:CD	CecWireles             # CEC Wireless R&D Ltd.
00:17:CE	MbInternat             # MB International Telecom Labs srl
00:17:CF	Imca-Gmbh
00:17:D0	OpticomCom             # Opticom Communications, LLC
00:17:D1	Nortel
00:17:D2	ThinlinxPt             # THINLINX PTY LTD
00:17:D3	EtymoticRe             # Etymotic Research, Inc.
00:17:D4	MonsoonMul             # Monsoon Multimedia, Inc
00:17:D5	SamsungEle             # Samsung Electronics Co., Ltd.
00:17:D6	BluechipsM             # Bluechips Microhouse Co.,Ltd.
00:17:D7	Input/Outp             # Input/Output Inc.
00:17:D8	MagnumSemi             # Magnum Semiconductor, Inc.
00:17:D9	Aai                    # AAI Corporation
00:17:DA	SpansLogic             # Spans Logic
00:17:DB	Private
00:17:DC	DaemyungZe             # DAEMYUNG ZERO1
00:17:DD	ClipsalAus             # Clipsal Australia
00:17:DE	AdvantageS             # Advantage Six Ltd
00:17:DF	Cisco                  # Cisco Systems
00:17:E0	Cisco                  # Cisco Systems
00:17:E1	DacosTechn             # DACOS Technologies Co., Ltd.
00:17:E2	MotorolaMo             # Motorola Mobile Devices
00:17:E3	TexasInstr             # Texas Instruments
00:17:E4	TexasInstr             # Texas Instruments
00:17:E5	TexasInstr             # Texas Instruments
00:17:E6	TexasInstr             # Texas Instruments
00:17:E7	TexasInstr             # Texas Instruments
00:17:E8	TexasInstr             # Texas Instruments
00:17:E9	TexasInstr             # Texas Instruments
00:17:EA	TexasInstr             # Texas Instruments
00:17:EB	TexasInstr             # Texas Instruments
00:17:EC	TexasInstr             # Texas Instruments
00:17:ED	Woojooit               # WooJooIT Ltd.
00:17:EE	MotorolaCh             # Motorola CHS
00:17:EF	BladeNetwo             # Blade Network Technologies, Inc.
00:17:F0	SzcomBroad             # SZCOM Broadband Network Technology Co.,Ltd
00:17:F1	RenuElectr             # Renu Electronics Pvt Ltd
00:17:F2	AppleCompu             # Apple Computer
00:17:F3	M/A-ComWir             # M/A-COM Wireless Systems
00:17:F4	ZeronAllia             # ZERON ALLIANCE
00:17:F5	Neoptek
00:17:F6	PyramidMer             # Pyramid Meriden Inc.
00:17:F7	CemSolutio             # CEM Solutions Pvt Ltd
00:17:F8	MotechIndu             # Motech Industries Inc.
00:17:F9	ForcomSpZO             # Forcom Sp. z o.o.
00:17:FA	Microsoft              # Microsoft Corporation
00:17:FB	Fa
00:17:FC	Suprema                # Suprema Inc.
00:17:FD	AmuletHotk             # Amulet Hotkey
00:17:FE	TalosSyste             # TALOS SYSTEM INC.
00:17:FF	Playline               # PLAYLINE Co.,Ltd.
00:18:00	Unigrand               # UNIGRAND LTD
00:18:01	ActiontecE             # Actiontec Electronics, Inc
00:18:02	AlphaNetwo             # Alpha Networks Inc.
00:18:03	ArcsoftSha             # ArcSoft Shanghai Co. LTD
00:18:04	E-TekDigit             # E-TEK DIGITAL TECHNOLOGY LIMITED
00:18:05	BeijingInh             # Beijing InHand Networking
00:18:06	HokkeiIndu             # Hokkei Industries Co., Ltd.
00:18:07	Fanstel                # Fanstel Corp.
00:18:08	Sightlogix             # SightLogix, Inc.
00:18:09	Cresyn
00:18:0A	MerakiNetw             # Meraki Networks, Inc.
00:18:0B	BrilliantT             # Brilliant Telecommunications
00:18:0C	OptelianAc             # Optelian Access Networks Corporation
00:18:0D	TerabytesS             # Terabytes Server Storage Tech Corp
00:18:0E	Avega                  # Avega Systems
00:18:0F	NokiaDanma             # Nokia Danmark A/S
00:18:10	IptradeSA              # IPTrade S.A.
00:18:11	NeurosTech             # Neuros Technology International, LLC.
00:18:12	BeijingXin             # Beijing Xinwei Telecom Technology Co., Ltd.
00:18:13	SonyEricss             # Sony Ericsson Mobile Communications
00:18:14	Mitutoyo               # Mitutoyo Corporation
00:18:15	GzTechnolo             # GZ Technologies, Inc.
00:18:16	Ubixon                 # Ubixon Co., Ltd.
00:18:17	DEShawRese             # D. E. Shaw Research, LLC
00:18:18	Cisco                  # Cisco Systems
00:18:19	Cisco                  # Cisco Systems
00:18:1A	AvermediaT             # AVerMedia Technologies Inc.
00:18:1B	TaijinMeta             # TaiJin Metal Co., Ltd.
00:18:1C	Exterity               # Exterity Limited
00:18:1D	AsiaElectr             # ASIA ELECTRONICS CO.,LTD
00:18:1E	GdxTechnol             # GDX Technologies Ltd.
00:18:1F	PalmmicroC             # Palmmicro Communications
00:18:20	W5networks
00:18:21	Sindoricoh
00:18:22	CecTelecom             # CEC TELECOM CO.,LTD.
00:18:23	DeltaElect             # Delta Electronics, Inc.
00:18:24	KimaldiEle             # Kimaldi Electronics, S.L.
00:18:25	Wavion                 # Wavion LTD
00:18:26	CaleAccess             # Cale Access AB
00:18:27	NecPhilips             # NEC PHILIPS UNIFIED SOLUTIONS NEDERLAND BV
00:18:28	E2vTechnol             # e2v technologies (UK) ltd.
00:18:29	Gatsometer
00:18:2A	TaiwanVide             # Taiwan Video & Monitor
00:18:2B	Softier
00:18:2C	AscendNetw             # Ascend Networks, Inc.
00:18:2D	ArtecGroup             # Artec Group O�
00:18:2E	WirelessVe             # Wireless Ventures USA
00:18:2F	TexasInstr             # Texas Instruments
00:18:30	TexasInstr             # Texas Instruments
00:18:31	TexasInstr             # Texas Instruments
00:18:32	TexasInstr             # Texas Instruments
00:18:33	TexasInstr             # Texas Instruments
00:18:34	TexasInstr             # Texas Instruments
00:18:35	Itc
00:18:36	RelianceEl             # Reliance Electric Limited
00:18:37	UniversalA             # Universal ABIT Co., Ltd.
00:18:38	PanaccessC             # PanAccess Communications,Inc.
00:18:39	Cisco-Link             # Cisco-Linksys LLC
00:18:3A	WestellTec             # Westell Technologies
00:18:3B	Cenits                 # CENITS Co., Ltd.
00:18:3C	EncoreSoft             # Encore Software Limited
00:18:3D	VertexLink             # Vertex Link Corporation
00:18:3E	Digilent               # Digilent, Inc
00:18:3F	2wire                  # 2Wire, Inc
00:18:40	3Phoenix               # 3 Phoenix, Inc.
00:18:41	HighTechCo             # High Tech Computer Corp
00:18:42	NokiaDanma             # Nokia Danmark A/S
00:18:43	Dawevision             # Dawevision Ltd
00:18:44	HeadsUpTec             # Heads Up Technologies, Inc.
00:18:45	NplPulsar              # NPL Pulsar Ltd.
00:18:46	CryptoSA               # Crypto S.A.
00:18:47	AcenetTech             # AceNet Technology Inc.
00:18:48	Vcom                   # Vcom Inc.
00:18:49	PigeonPoin             # Pigeon Point Systems
00:18:4A	Catcher                # Catcher, Inc.
00:18:4B	LasVegasGa             # Las Vegas Gaming, Inc.
00:18:4C	BogenCommu             # Bogen Communications
00:18:4D	Netgear                # Netgear Inc.
00:18:4E	LianheTech             # Lianhe Technologies, Inc.
00:18:4F	8WaysTechn             # 8 Ways Technology Corp.
00:18:50	SecfoneKft             # Secfone Kft
00:18:51	Swsoft
00:18:52	StorlinkSe             # StorLink Semiconductors, Inc.
00:18:53	AteraNetwo             # Atera Networks LTD.
00:18:54	Argard                 # Argard Co., Ltd
00:18:55	Aeromariti             # Aeromaritime Systembau GmbH
00:18:56	Eyefi                  # EyeFi, Inc
00:18:57	UnileverR&             # Unilever R&D
00:18:58	Tagmaster              # TagMaster AB
00:18:59	Strawberry             # Strawberry Linux Co.,Ltd.
00:18:5A	Ucontrol               # uControl, Inc.
00:18:5B	NetworkChe             # Network Chemistry, Inc
00:18:5C	EdsLabPte              # EDS Lab Pte Ltd
00:18:5D	TaiguenTec             # TAIGUEN TECHNOLOGY (SHEN-ZHEN) CO., LTD.
00:18:5E	Nexterm                # Nexterm Inc.
00:18:5F	Tac                    # TAC Inc.
00:18:60	SimTechnol             # SIM Technology Group Shanghai Simcom Ltd.,
00:18:61	Ooma                   # Ooma, Inc.
00:18:62	SeagateTec             # Seagate Technology
00:18:63	VeritechEl             # Veritech Electronics Limited
00:18:64	Cybectec               # Cybectec Inc.
00:18:65	BayerDiagn             # Bayer Diagnostics Sudbury Ltd
00:18:66	LeutronVis             # Leutron Vision
00:18:67	EvolutionR             # Evolution Robotics Retail
00:18:68	Scientific             # Scientific Atlanta, A Cisco Company
00:18:69	Kingjim
00:18:6A	GlobalLink             # Global Link Digital Technology Co,.LTD
00:18:6B	SambuCommu             # Sambu Communics CO., LTD.
00:18:6C	Neonode                # Neonode AB
00:18:6D	ZhenjiangS             # Zhenjiang Sapphire Electronic Industry CO.
00:18:6E	3comEurope             # 3COM Europe Ltd
00:18:6F	SethaIndus             # Setha Industria Eletronica LTDA
00:18:70	E28Shangha             # E28 Shanghai Limited
00:18:71	GlobalData             # Global Data Services
00:18:72	ExpertiseE             # Expertise Engineering
00:18:73	Cisco                  # Cisco Systems
00:18:74	Cisco                  # Cisco Systems
00:18:75	AnaciseTes             # AnaCise Testnology Pte Ltd
00:18:76	Wowwee                 # WowWee Ltd.
00:18:77	Amplex                 # Amplex A/S
00:18:78	Mackware               # Mackware GmbH
00:18:79	Dsys
00:18:7A	Wiremold
00:18:7B	4nsys                  # 4NSYS Co. Ltd.
00:18:7C	Intercross             # INTERCROSS, LLC
00:18:7D	ArmorlinkS             # Armorlink shanghai Co. Ltd
00:18:7E	RgbSpectru             # RGB Spectrum
00:18:7F	Zodianet
00:18:80	Mobilygen
00:18:81	BuyangElec             # Buyang Electronics Industrial Co., Ltd
00:18:82	HuaweiTech             # Huawei Technologies Co., Ltd.
00:18:83	Formosa21              # FORMOSA21 INC.
00:18:84	Fon
00:18:85	Avigilon               # Avigilon Corporation
00:18:86	El-Tech                # EL-TECH, INC.
00:18:87	Metasystem             # Metasystem SpA
00:18:88	GotiveAS               # GOTIVE a.s.
00:18:89	WinnetSolu             # WinNet Solutions Limited
00:18:8A	InfinovaLl             # Infinova LLC
00:18:8B	Dell
00:18:8C	MobileActi             # Mobile Action Technology Inc.
00:18:8D	NokiaDanma             # Nokia Danmark A/S
00:18:8E	Ekahau                 # Ekahau, Inc.
00:18:8F	Montgomery             # Montgomery Technology, Inc.
00:18:90	RadiocomSR             # RadioCOM, s.r.o.
00:18:91	ZhongshanG             # Zhongshan General K-mate Electronics Co., Ltd
00:18:92	Ads-Tec                # ads-tec GmbH
00:18:93	ShenzhenPh             # SHENZHEN PHOTON BROADBAND TECHNOLOGY CO.,LTD
00:18:94	Zimocom
00:18:95	HansunTech             # Hansun Technologies Inc.
00:18:96	GreatWellE             # Great Well Electronic LTD
00:18:97	Jess-LinkP             # JESS-LINK PRODUCTS Co., LTD
00:18:98	KingstateE             # KINGSTATE ELECTRONICS CORPORATION
00:18:99	ShenzhenJi             # ShenZhen jieshun Science&Technology Industry CO,LTD.
00:18:9A	HanaMicron             # HANA Micron Inc.
00:18:9B	Thomson                # Thomson Inc.
00:18:9C	Weldex                 # Weldex Corporation
00:18:9D	Navcast                # Navcast Inc.
00:18:9E	Omnikey                # OMNIKEY GmbH.
00:18:9F	Lenntek                # Lenntek Corporation
00:18:A0	CiermaAsce             # Cierma Ascenseurs
00:18:A1	TiqitCompu             # Tiqit Computers, Inc.
00:18:A2	XipTechnol             # XIP Technology AB
00:18:A3	ZippyTechn             # ZIPPY TECHNOLOGY CORP.
00:18:A4	MotorolaMo             # Motorola Mobile Devices
00:18:A5	AdigitTech             # ADigit Technologies Corp.
00:18:A6	Persistent             # Persistent Systems, LLC
00:18:A7	YoggieSecu             # Yoggie Security Systems LTD.
00:18:A8	AnnealTech             # AnNeal Technology Inc.
00:18:A9	EthernetDi             # Ethernet Direct Corporation
00:18:AA	Private
00:18:AB	BeijingLhw             # BEIJING LHWT MICROELECTRONICS INC.
00:18:AC	ShanghaiJi             # Shanghai Jiao Da HISYS Technology Co. Ltd.
00:18:AD	NidecSanky             # NIDEC SANKYO CORPORATION
00:18:AE	TongweiVid             # Tongwei Video Technology CO.,LTD
00:18:AF	SamsungEle             # Samsung Electronics Co., Ltd.
00:18:B0	Nortel
00:18:B1	BladeNetwo             # Blade Network Technologies
00:18:B2	AdeunisRf              # ADEUNIS RF
00:18:B3	TecWizhome             # TEC WizHome Co., Ltd.
00:18:B4	DawonMedia             # Dawon Media Inc.
00:18:B5	MagnaCarta             # Magna Carta
00:18:B6	S3c                    # S3C, Inc.
00:18:B7	D3LedLlc               # D3 LED, LLC
00:18:B8	NewVoiceIn             # New Voice International AG
00:18:B9	Cisco                  # Cisco Systems
00:18:BA	Cisco                  # Cisco Systems
00:18:BB	EliwellCon             # Eliwell Controls srl
00:18:BC	ZaoNvpBoli             # ZAO NVP Bolid
00:18:BD	ShenzhenDv             # SHENZHEN DVBWORLD TECHNOLOGY CO., LTD.
00:18:BE	Ansa                   # ANSA Corporation
00:18:BF	EssenceTec             # Essence Technology Solution, Inc.
00:18:C0	MotorolaCh             # Motorola CHS
00:18:C1	AlmitecInf             # Almitec Inform�tica e Com�rcio Ltda.
00:18:C2	Firetide               # Firetide, Inc
00:18:C3	C&SMicrowa             # C&S Microwave
00:18:C4	RabaTechno             # Raba Technologies LLC
00:18:C5	NokiaDanma             # Nokia Danmark A/S
00:18:C6	OpwFuelMan             # OPW Fuel Management Systems
00:18:C7	RealTimeAu             # Real Time Automation
00:18:C8	Isonas                 # ISONAS Inc.
00:18:C9	EopsTechno             # EOps Technology Limited
00:18:CA	Viprinet               # Viprinet GmbH
00:18:CB	TecobestTe             # Tecobest Technology Limited
00:18:CC	AxiohmSas              # AXIOHM SAS
00:18:CD	EraeElectr             # Erae Electronics Industry Co., Ltd
00:18:CE	Dreamtech              # Dreamtech Co., Ltd
00:18:CF	BaldorElec             # Baldor Electric Company
00:18:D0	@Road                  # @ROAD Inc
00:18:D1	SiemensHom             # Siemens Home & Office Comm. Devices
00:18:D2	High-GainA             # High-Gain Antennas LLC
00:18:D3	Teamcast
00:18:D4	UnifiedDis             # Unified Display Interface SIG
00:18:D5	Reigncom
00:18:D6	Swirlnet               # Swirlnet A/S
00:18:D7	JavadNavig             # Javad Navigation Systems Inc.
00:18:D8	ArchMeter              # ARCH METER Corporation
00:18:D9	SantoshaIn             # Santosha Internatonal, Inc
00:18:DA	AmberWirel             # AMBER wireless GmbH
00:18:DB	EplTechnol             # EPL Technology Ltd
00:18:DC	Prostar                # Prostar Co., Ltd.
00:18:DD	Silicondus             # Silicondust Engineering Ltd
00:18:DE	Intel                  # Intel Corporation
00:18:DF	Morey                  # The Morey Corporation
00:18:E0	Anaveo
00:18:E1	VerkerkSer             # Verkerk Service Systemen
00:18:E2	TopdataSis             # Topdata Sistemas de Automacao Ltda
00:18:E3	Visualgate             # Visualgate Systems, Inc.
00:18:E4	Yiguang
00:18:E5	Adhoco                 # Adhoco AG
00:18:E6	ComputerHa             # Computer Hardware Design SIA
00:18:E7	CameoCommu             # Cameo Communications, INC.
00:18:E8	Hacetron               # Hacetron Corporation
00:18:E9	Numata                 # Numata Corporation
00:18:EA	Alltec                 # Alltec GmbH
00:18:EB	BrovisWire             # BroVis Wireless Networks
00:18:EC	WeldingTec             # Welding Technology Corporation
00:18:ED	AccutechIn             # ACCUTECH INTERNATIONAL CO., LTD.
00:18:EE	VideologyI             # Videology Imaging Solutions, Inc.
00:18:EF	EscapeComm             # Escape Communications, Inc.
00:18:F0	Joytoto                # JOYTOTO Co., Ltd.
00:18:F1	ChunichiDe             # Chunichi Denshi Co.,LTD.
00:18:F2	BeijingTia             # Beijing Tianyu Communication Equipment Co., Ltd
00:18:F3	AsustekCom             # ASUSTek COMPUTER INC.
00:18:F4	EoTechnics             # EO TECHNICS Co., Ltd.
00:18:F5	ShenzhenSt             # Shenzhen Streaming Video Technology Company Limited
00:18:F6	ThomsonTel             # Thomson Telecom Belgium
00:18:F7	KameleonTe             # Kameleon Technologies
00:18:F8	Cisco-Link             # Cisco-Linksys LLC
00:18:F9	Vvond                  # VVOND, Inc.
00:18:FA	YushinPrec             # Yushin Precision Equipment Co.,Ltd.
00:18:FB	ComproTech             # Compro Technology
00:18:FC	AltecElect             # Altec Electronic AG
00:18:FD	OptimalTec             # Optimal Technologies International Inc.
00:18:FE	HewlettPac             # Hewlett Packard
00:18:FF	Powerquatt             # PowerQuattro Co.
00:19:00	Intelliver             # Intelliverese - DBA Voicecom
00:19:01	F1media
00:19:02	CambridgeC             # Cambridge Consultants Ltd
00:19:03	BigfootNet             # Bigfoot Networks Inc
00:19:04	WbElectron             # WB Electronics Sp. z o.o.
00:19:05	SchrackSec             # SCHRACK Seconet AG
00:19:06	Cisco                  # Cisco Systems
00:19:07	Cisco                  # Cisco Systems
00:19:08	Duaxes                 # Duaxes Corporation
00:19:09	Devi                   # Devi A/S
00:19:0A	Hasware                # HASWARE INC.
00:19:0B	SouthernVi             # Southern Vision Systems, Inc.
00:19:0C	EncoreElec             # Encore Electronics, Inc.
00:19:0D	Ieee1394c              # IEEE 1394c
00:19:0E	AtechTechn             # Atech Technology Co., Ltd.
00:19:0F	Advansus               # Advansus Corp.
00:19:10	KnickElekt             # Knick Elektronische Messgeraete GmbH & Co. KG
00:19:11	JustInMobi             # Just In Mobile Information Technologies (Shanghai) Co., Ltd.
00:19:12	Welcat                 # Welcat Inc
00:19:13	Chuang-YiN             # Chuang-Yi Network Equipment Co.Ltd.
00:19:14	Winix                  # Winix Co., Ltd
00:19:15	Tecom                  # TECOM Co., Ltd.
00:19:16	Paytec                 # PayTec AG
00:19:17	Posiflex               # Posiflex Inc.
00:19:18	Interactiv             # Interactive Wear AG
00:19:19	Astel                  # ASTEL Inc.
00:19:1A	Irlink
00:19:1B	SputnikEng             # Sputnik Engineering AG
00:19:1C	Sensicast              # Sensicast Systems
00:19:1D	Nintendo               # Nintendo Co.,Ltd.
00:19:1E	Beyondwiz              # Beyondwiz Co., Ltd.
00:19:1F	MicrolinkC             # Microlink communications Inc.
00:19:20	KumeElectr             # KUME electric Co.,Ltd.
00:19:21	Elitegroup             # Elitegroup Computer System Co.
00:19:22	CmComandos             # CM Comandos Lineares
00:19:23	PhonexKore             # Phonex Korea Co., LTD.
00:19:24	LbnlEngine             # LBNL  Engineering
00:19:25	Intelicis              # Intelicis Corporation
00:19:26	Bitsgen                # BitsGen Co., Ltd.
00:19:27	Imcosys                # ImCoSys Ltd
00:19:28	SiemensTra             # Siemens AG, Transportation Systems
00:19:29	2m2bMontad             # 2M2B Montadora de Maquinas Bahia Brasil LTDA
00:19:2A	AntiopeAss             # Antiope Associates
00:19:2B	Hexagram               # Hexagram, Inc.
00:19:2C	MotorolaMo             # Motorola Mobile Devices
00:19:2D	Nokia                  # Nokia Corporation
00:19:2E	SpectralIn             # Spectral Instruments, Inc.
00:19:2F	Cisco                  # Cisco Systems
00:19:30	Cisco                  # Cisco Systems
00:19:31	Balluff                # Balluff GmbH
00:19:32	GudeAnalog             # Gude Analog- und Digialsysteme GmbH
00:19:33	Strix                  # Strix Systems, Inc.
00:19:34	TrendonTou             # TRENDON TOUCH TECHNOLOGY CORP.
00:19:35	DuerrDenta             # Duerr Dental GmbH & Co. KG
00:19:36	SterliteOp             # STERLITE OPTICAL TECHNOLOGIES LIMITED
00:19:37	Commercegu             # CommerceGuard AB
00:19:38	UmbCommuni             # UMB Communications Co., Ltd.
00:19:39	Gigamips
00:19:3A	Oesolution             # OESOLUTIONS
00:19:3B	Deliberant             # Deliberant LLC
00:19:3C	HighpointT             # HighPoint Technologies Incorporated
00:19:3D	GmcGuardia             # GMC Guardian Mobility Corp.
00:19:3E	PirelliBro             # PIRELLI BROADBAND SOLUTIONS
00:19:3F	RdiTechnol             # RDI technology(Shenzhen) Co.,LTD
00:19:40	Rackable               # Rackable Systems
00:19:41	PitneyBowe             # Pitney Bowes, Inc
00:19:42	OnSoftware             # ON SOFTWARE INTERNATIONAL LIMITED
00:19:43	Belden
00:19:44	FossilPart             # Fossil Partners, L.P.
00:19:45	Ten-Tec                # Ten-Tec Inc.
00:19:46	CianetIndu             # Cianet Industria e Comercio S/A
00:19:47	Scientific             # Scientific Atlanta, A Cisco Company
00:19:48	Airespider             # AireSpider Networks
00:19:49	TentelComt             # TENTEL  COMTECH CO., LTD.
00:19:4A	Testo                  # TESTO AG
00:19:4B	SagemCommu             # SAGEM COMMUNICATION
00:19:4C	FujianStel             # Fujian Stelcom information & Technology CO.,Ltd
00:19:4D	AvagoTechn             # Avago Technologies Sdn Bhd
00:19:4E	UltraElect             # Ultra Electronics - TCS (Tactical Communication Systems)
00:19:4F	NokiaDanma             # Nokia Danmark A/S
00:19:50	HarmanMult             # Harman Multimedia
00:19:51	NetconsSRO             # NETCONS, s.r.o.
00:19:52	Acogito                # ACOGITO Co., Ltd
00:19:53	Chainleade             # Chainleader Communications Corp.
00:19:54	Leaf                   # Leaf Corporation.
00:19:55	Cisco                  # Cisco Systems
00:19:56	Cisco                  # Cisco Systems
00:19:57	SaafnetCan             # Saafnet Canada Inc.
00:19:58	BluetoothS             # Bluetooth SIG, Inc.
00:19:59	StaccatoCo             # Staccato Communications Inc.
00:19:5A	JenaerAntr             # Jenaer Antriebstechnik GmbH
00:19:5B	D-Link                 # D-Link Corporation
00:19:5C	Innotech               # Innotech Corporation
00:19:5D	ShenzhenXi             # ShenZhen XinHuaTong Opto Electronics Co.,Ltd
00:19:5E	MotorolaCh             # Motorola CHS
00:19:5F	ValemountN             # Valemount Networks Corporation
00:19:60	Opticom                # Opticom Inc.
00:19:61	Blaupunkt              # Blaupunkt GmbH
00:19:62	Commercian             # Commerciant, LP
00:19:63	SonyEricss             # Sony Ericsson Mobile Communications AB
00:19:64	Doorking               # Doorking Inc.
00:19:65	YuhuaTelte             # YuHua TelTech (ShangHai) Co., Ltd.
00:19:66	AsiarockTe             # Asiarock Technology Limited
00:1C:7C	Perq                   # PERQ SYSTEMS CORPORATION
00:20:00	LexmarkInt             # LEXMARK INTERNATIONAL, INC.
00:20:01	DspSolutio             # DSP SOLUTIONS, INC.
00:20:02	SeritechEn             # SERITECH ENTERPRISE CO., LTD.
00:20:03	PixelPower             # PIXEL POWER LTD.
00:20:04	Yamatake-H             # YAMATAKE-HONEYWELL CO., LTD.
00:20:05	SimpleTech             # SIMPLE TECHNOLOGY
00:20:06	GarrettCom             # GARRETT COMMUNICATIONS, INC.
00:20:07	Sfa                    # SFA, INC.
00:20:08	CableCompu             # CABLE & COMPUTER TECHNOLOGY
00:20:09	PackardBel             # PACKARD BELL ELEC., INC.
00:20:0A	Source-Com             # SOURCE-COMM CORP.
00:20:0B	Octagon                # OCTAGON SYSTEMS CORP.
00:20:0C	Adastra                # ADASTRA SYSTEMS CORP.
00:20:0D	CarlZeiss              # CARL ZEISS
00:20:0E	SatelliteT             # SATELLITE TECHNOLOGY MGMT, INC
00:20:0F	Tanbac                 # TANBAC CO., LTD.
00:20:10	JeolSystem             # JEOL SYSTEM TECHNOLOGY CO. LTD
00:20:11	Canopus                # CANOPUS CO., LTD.
00:20:12	Camtronics             # CAMTRONICS MEDICAL SYSTEMS
00:20:13	Diversifie             # DIVERSIFIED TECHNOLOGY, INC.
00:20:14	GlobalView             # GLOBAL VIEW CO., LTD.
00:20:15	ActisCompu             # ACTIS COMPUTER SA
00:20:16	ShowaElect             # SHOWA ELECTRIC WIRE & CABLE CO
00:20:17	Orbotech
00:20:18	CisTechnol             # CIS TECHNOLOGY INC.
00:20:19	Ohler                  # OHLER GmbH
00:20:1A	MrvCommuni             # MRV Communications, Inc.
00:20:1B	NorthernTe             # NORTHERN TELECOM/NETWORK
00:20:1C	Excel                  # EXCEL, INC.
00:20:1D	KatanaProd             # KATANA PRODUCTS
00:20:1E	Netquest               # NETQUEST CORPORATION
00:20:1F	BestPowerT             # BEST POWER TECHNOLOGY, INC.
00:20:20	MegatronCo             # MEGATRON COMPUTER INDUSTRIES PTY, LTD.
00:20:21	Algorithms             # ALGORITHMS SOFTWARE PVT. LTD.
00:20:22	NmsCommuni             # NMS Communications
00:20:23	TCTechnolo             # T.C. TECHNOLOGIES PTY. LTD
00:20:24	PacificCom             # PACIFIC COMMUNICATION SCIENCES
00:20:25	ControlTec             # CONTROL TECHNOLOGY, INC.
00:20:26	Amkly                  # AMKLY SYSTEMS, INC.
00:20:27	MingFortun             # MING FORTUNE INDUSTRY CO., LTD
00:20:28	WestEgg                # WEST EGG SYSTEMS, INC.
00:20:29	Teleproces             # TELEPROCESSING PRODUCTS, INC.
00:20:2A	NVDzine                # N.V. DZINE
00:20:2B	AdvancedTe             # ADVANCED TELECOMMUNICATIONS MODULES, LTD.
00:20:2C	Welltronix             # WELLTRONIX CO., LTD.
00:20:2D	Taiyo                  # TAIYO CORPORATION
00:20:2E	DaystarDig             # DAYSTAR DIGITAL
00:20:2F	ZetaCommun             # ZETA COMMUNICATIONS, LTD.
00:20:30	AnalogDigi             # ANALOG & DIGITAL SYSTEMS
00:20:31	Ertec                  # ERTEC GmbH
00:20:32	AlcatelTai             # ALCATEL TAISEL
00:20:33	SynapseTec             # SYNAPSE TECHNOLOGIES, INC.
00:20:34	RotecIndus             # ROTEC INDUSTRIEAUTOMATION GMBH
00:20:35	Ibm                    # IBM CORPORATION
00:20:36	BmcSoftwar             # BMC SOFTWARE
00:20:37	SeagateTec             # SEAGATE TECHNOLOGY
00:20:38	VmeMicrosy             # VME MICROSYSTEMS INTERNATIONAL CORPORATION
00:20:39	Scinets
00:20:3A	DigitalBi0             # DIGITAL BI0METRICS INC.
00:20:3B	Wisdm                  # WISDM LTD.
00:20:3C	Eurotime               # EUROTIME AB
00:20:3D	NovarElect             # NOVAR ELECTRONICS CORPORATION
00:20:3E	LogicanTec             # LogiCan Technologies, Inc.
00:20:3F	Juki                   # JUKI CORPORATION
00:20:40	MotorolaBr             # Motorola Broadband Communications Sector
00:20:41	DataNet                # DATA NET
00:20:42	Datametric             # DATAMETRICS CORP.
00:20:43	Neuron                 # NEURON COMPANY LIMITED
00:20:44	GenitechPt             # GENITECH PTY LTD
00:20:45	IonNetwork             # ION Networks, Inc.
00:20:46	Ciprico                # CIPRICO, INC.
00:20:47	Steinbrech             # STEINBRECHER CORP.
00:20:48	MarconiCom             # Marconi Communications
00:20:49	Comtron                # COMTRON, INC.
00:20:4A	Pronet                 # PRONET GMBH
00:20:4B	Autocomput             # AUTOCOMPUTER CO., LTD.
00:20:4C	MitronComp             # MITRON COMPUTER PTE LTD.
00:20:4D	Inovis                 # INOVIS GMBH
00:20:4E	NetworkSec             # NETWORK SECURITY SYSTEMS, INC.
00:20:4F	DeutscheAe             # DEUTSCHE AEROSPACE AG
00:20:50	KoreaCompu             # KOREA COMPUTER INC.
00:20:51	Verilink               # Verilink Corporation
00:20:52	Ragula                 # RAGULA SYSTEMS
00:20:53	Huntsville             # HUNTSVILLE MICROSYSTEMS, INC.
00:20:54	EasternRes             # EASTERN RESEARCH, INC.
00:20:55	Altech                 # ALTECH CO., LTD.
00:20:56	Neoproduct             # NEOPRODUCTS
00:20:57	TitzeDaten             # TITZE DATENTECHNIK GmbH
00:20:58	AlliedSign             # ALLIED SIGNAL INC.
00:20:59	MiroComput             # MIRO COMPUTER PRODUCTS AG
00:20:5A	ComputerId             # COMPUTER IDENTICS
00:20:5B	KentroxLlc             # Kentrox, LLC
00:20:5C	InternetOf             # InterNet Systems of Florida, Inc.
00:20:5D	NanomaticO             # NANOMATIC OY
00:20:5E	CastleRock             # CASTLE ROCK, INC.
00:20:5F	GammadataC             # GAMMADATA COMPUTER GMBH
00:20:60	AlcatelIta             # ALCATEL ITALIA S.p.A.
00:20:61	DynatechCo             # DYNATECH COMMUNICATIONS, INC.
00:20:62	ScorpionLo             # SCORPION LOGIC, LTD.
00:20:63	WiproInfot             # WIPRO INFOTECH LTD.
00:20:64	ProtecMicr             # PROTEC MICROSYSTEMS, INC.
00:20:65	SupernetNe             # SUPERNET NETWORKING INC.
00:20:66	GeneralMag             # GENERAL MAGIC, INC.
00:20:67	Private
00:20:68	Isdyne
00:20:69	Isdn                   # ISDN SYSTEMS CORPORATION
00:20:6A	OsakaCompu             # OSAKA COMPUTER CORP.
00:20:6B	KonicaMino             # KONICA MINOLTA HOLDINGS, INC.
00:20:6C	EvergreenT             # EVERGREEN TECHNOLOGY CORP.
00:20:6D	DataRace               # DATA RACE, INC.
00:20:6E	Xact                   # XACT, INC.
00:20:6F	Flowpoint              # FLOWPOINT CORPORATION
00:20:70	Hynet                  # HYNET, LTD.
00:20:71	Ibr                    # IBR GMBH
00:20:72	WorklinkIn             # WORKLINK INNOVATIONS
00:20:73	Fusion                 # FUSION SYSTEMS CORPORATION
00:20:74	Sungwoon               # SUNGWOON SYSTEMS
00:20:75	MotorolaCo             # MOTOROLA COMMUNICATION ISRAEL
00:20:76	Reudo                  # REUDO CORPORATION
00:20:77	Kardios                # KARDIOS SYSTEMS CORP.
00:20:78	Runtop                 # RUNTOP, INC.
00:20:79	Mikron                 # MIKRON GMBH
00:20:7A	WiseCommun             # WiSE Communications, Inc.
00:20:7B	Intel                  # Intel Corporation
00:20:7C	Autec                  # AUTEC GmbH
00:20:7D	AdvancedCo             # ADVANCED COMPUTER APPLICATIONS
00:20:7E	Finecom                # FINECOM Co., Ltd.
00:20:7F	KyoeiSangy             # KYOEI SANGYO CO., LTD.
00:20:80	SynergyUk              # SYNERGY (UK) LTD.
00:20:81	TitanElect             # TITAN ELECTRONICS
00:20:82	Oneac                  # ONEAC CORPORATION
00:20:83	Presticom              # PRESTICOM INCORPORATED
00:20:84	OcePrintin             # OCE PRINTING SYSTEMS, GMBH
00:20:85	3Com
00:20:86	MicrotechE             # MICROTECH ELECTRONICS LIMITED
00:20:87	MemotecCom             # MEMOTEC COMMUNICATIONS CORP.
00:20:88	GlobalVill             # GLOBAL VILLAGE COMMUNICATION
00:20:89	T3plusNetw             # T3PLUS NETWORKING, INC.
00:20:8A	SonixCommu             # SONIX COMMUNICATIONS, LTD.
00:20:8B	LapisTechn             # LAPIS TECHNOLOGIES, INC.
00:20:8C	GalaxyNetw             # GALAXY NETWORKS, INC.
00:20:8D	CmdTechnol             # CMD TECHNOLOGY
00:20:8E	ChevinSoft             # CHEVIN SOFTWARE ENG. LTD.
00:20:8F	EciTelecom             # ECI TELECOM LTD.
00:20:90	AdvancedCo             # ADVANCED COMPRESSION TECHNOLOGY, INC.
00:20:91	J125Nation             # J125, NATIONAL SECURITY AGENCY
00:20:92	ChessEngin             # CHESS ENGINEERING B.V.
00:20:93	LandingsTe             # LANDINGS TECHNOLOGY CORP.
00:20:94	Cubix                  # CUBIX CORPORATION
00:20:95	RivaElectr             # RIVA ELECTRONICS
00:20:96	Invensys
00:20:97	AppliedSig             # APPLIED SIGNAL TECHNOLOGY
00:20:98	Hectronic              # HECTRONIC AB
00:20:99	BonElectri             # BON ELECTRIC CO., LTD.
00:20:9A	3do                    # THE 3DO COMPANY
00:20:9B	ErsatElect             # ERSAT ELECTRONIC GMBH
00:20:9C	PrimaryAcc             # PRIMARY ACCESS CORP.
00:20:9D	LippertAut             # LIPPERT AUTOMATIONSTECHNIK
00:20:9E	BrownSOper             # BROWN'S OPERATING SYSTEM SERVICES, LTD.
00:20:9F	MercuryCom             # MERCURY COMPUTER SYSTEMS, INC.
00:20:A0	OaLaborato             # OA LABORATORY CO., LTD.
00:20:A1	Dovatron
00:20:A2	GalcomNetw             # GALCOM NETWORKING LTD.
00:20:A3	Divicom                # DIVICOM INC.
00:20:A4	Multipoint             # MULTIPOINT NETWORKS
00:20:A5	ApiEnginee             # API ENGINEERING
00:20:A6	Proxim                 # PROXIM, INC.
00:20:A7	PairgainTe             # PAIRGAIN TECHNOLOGIES, INC.
00:20:A8	SastTechno             # SAST TECHNOLOGY CORP.
00:20:A9	WhiteHorse             # WHITE HORSE INDUSTRIAL
00:20:AA	DigimediaV             # DIGIMEDIA VISION LTD.
00:20:AB	MicroIndus             # MICRO INDUSTRIES CORP.
00:20:AC	InterflexD             # INTERFLEX DATENSYSTEME GMBH
00:20:AD	Linq                   # LINQ SYSTEMS
00:20:AE	OrnetDataC             # ORNET DATA COMMUNICATION TECH.
00:20:AF	3com                   # 3COM CORPORATION
00:20:B0	GatewayDev             # GATEWAY DEVICES, INC.
00:20:B1	ComtechRes             # COMTECH RESEARCH INC.
00:20:B2	GkdGesells             # GKD Gesellschaft Fur Kommunikation Und Datentechnik
00:20:B3	ScltecComm             # SCLTEC COMMUNICATIONS SYSTEMS
00:20:B4	TermaElekt             # TERMA ELEKTRONIK AS
00:20:B5	YaskawaEle             # YASKAWA ELECTRIC CORPORATION
00:20:B6	AgileNetwo             # AGILE NETWORKS, INC.
00:20:B7	NamaquaCom             # NAMAQUA COMPUTERWARE
00:20:B8	PrimeOptio             # PRIME OPTION, INC.
00:20:B9	Metricom               # METRICOM, INC.
00:20:BA	CenterForH             # CENTER FOR HIGH PERFORMANCE
00:20:BB	Zax                    # ZAX CORPORATION
00:20:BC	LongReachN             # Long Reach Networks Pty Ltd
00:20:BD	NiobraraRD             # NIOBRARA R & D CORPORATION
00:20:BE	LanAccess              # LAN ACCESS CORP.
00:20:BF	AehrTest               # AEHR TEST SYSTEMS
00:20:C0	PulseElect             # PULSE ELECTRONICS, INC.
00:20:C1	Saxa                   # SAXA, Inc.
00:20:C2	TexasMemor             # TEXAS MEMORY SYSTEMS, INC.
00:20:C3	CounterSol             # COUNTER SOLUTIONS LTD.
00:20:C4	Inet                   # INET,INC.
00:20:C5	EagleTechn             # EAGLE TECHNOLOGY
00:20:C6	Nectec
00:20:C7	AkaiProfes             # AKAI Professional M.I. Corp.
00:20:C8	Larscom                # LARSCOM INCORPORATED
00:20:C9	VictronBv              # VICTRON BV
00:20:CA	DigitalOce             # DIGITAL OCEAN
00:20:CB	PretecElec             # PRETEC ELECTRONICS CORP.
00:20:CC	DigitalSer             # DIGITAL SERVICES, LTD.
00:20:CD	HybridNetw             # HYBRID NETWORKS, INC.
00:20:CE	LogicalDes             # LOGICAL DESIGN GROUP, INC.
00:20:CF	TestMeasur             # TEST & MEASUREMENT SYSTEMS INC
00:20:D0	Versalynx              # VERSALYNX CORPORATION
00:20:D1	Microcompu             # MICROCOMPUTER SYSTEMS (M) SDN.
00:20:D2	RadDataCom             # RAD DATA COMMUNICATIONS, LTD.
00:20:D3	OstOuestSt             # OST (OUEST STANDARD TELEMATIQU
00:20:D4	Cabletron-             # CABLETRON - ZEITTNET INC.
00:20:D5	Vipa                   # VIPA GMBH
00:20:D6	Breezecom
00:20:D7	JapanMinic             # JAPAN MINICOMPUTER SYSTEMS CO., Ltd.
00:20:D8	NortelNetw             # Nortel Networks
00:20:D9	PanasonicT             # PANASONIC TECHNOLOGIES, INC./MIECO-US
00:20:DA	AlcatelNor             # Alcatel North America ESD
00:20:DB	XnetTechno             # XNET TECHNOLOGY, INC.
00:20:DC	DensitronT             # DENSITRON TAIWAN LTD.
00:20:DD	CybertecPt             # Cybertec Pty Ltd
00:20:DE	JapanDigit             # JAPAN DIGITAL LABORAT'Y CO.LTD
00:20:DF	KyosanElec             # KYOSAN ELECTRIC MFG. CO., LTD.
00:20:E0	ActiontecE             # Actiontec Electronics, Inc.
00:20:E1	AlamarElec             # ALAMAR ELECTRONICS
00:20:E2	Informatio             # INFORMATION RESOURCE ENGINEERING
00:20:E3	McdKencom              # MCD KENCOM CORPORATION
00:20:E4	HsingTechE             # HSING TECH ENTERPRISE CO., LTD
00:20:E5	ApexData               # APEX DATA, INC.
00:20:E6	LidkopingM             # LIDKOPING MACHINE TOOLS AB
00:20:E7	B&WNuclear             # B&W NUCLEAR SERVICE COMPANY
00:20:E8	Datatrek               # DATATREK CORPORATION
00:20:E9	Dantel
00:20:EA	EfficientN             # EFFICIENT NETWORKS, INC.
00:20:EB	Cincinnati             # CINCINNATI MICROWAVE, INC.
00:20:EC	Techware               # TECHWARE SYSTEMS CORP.
00:20:ED	Giga-ByteT             # GIGA-BYTE TECHNOLOGY CO., LTD.
00:20:EE	Gtech                  # GTECH CORPORATION
00:20:EF	Usc                    # USC CORPORATION
00:20:F0	UniversalM             # UNIVERSAL MICROELECTRONICS CO.
00:20:F1	AltosIndia             # ALTOS INDIA LIMITED
00:20:F2	SunMicrosy             # SUN MICROSYSTEMS, INC.
00:20:F3	Raynet                 # RAYNET CORPORATION
00:20:F4	Spectrix               # SPECTRIX CORPORATION
00:20:F5	Pandatel               # PANDATEL AG
00:20:F6	NetTekAndK             # NET TEK  AND KARLNET, INC.
00:20:F7	Cyberdata
00:20:F8	CarreraCom             # CARRERA COMPUTERS, INC.
00:20:F9	ParalinkNe             # PARALINK NETWORKS, INC.
00:20:FA	Gde                    # GDE SYSTEMS, INC.
00:20:FB	OctelCommu             # OCTEL COMMUNICATIONS CORP.
00:20:FC	Matrox
00:20:FD	ItvTechnol             # ITV TECHNOLOGIES, INC.
00:20:FE	Topware/Gr             # TOPWARE INC. / GRAND COMPUTER
00:20:FF	Symmetrica             # SYMMETRICAL TECHNOLOGIES
00:26:54	3com                   # 3Com Corporation
00:30:00	AllwellTec             # ALLWELL TECHNOLOGY CORP.
00:30:01	Smp
00:30:02	ExpandNetw             # Expand Networks
00:30:03	Phasys                 # Phasys Ltd.
00:30:04	LeadtekRes             # LEADTEK RESEARCH INC.
00:30:05	FujitsuSie             # Fujitsu Siemens Computers
00:30:06	Superpower             # SUPERPOWER COMPUTER
00:30:07	Opti                   # OPTI, INC.
00:30:08	AvioDigita             # AVIO DIGITAL, INC.
00:30:09	TachionNet             # Tachion Networks, Inc.
00:30:0A	Aztech                 # AZTECH SYSTEMS LTD.
00:30:0B	MphaseTech             # mPHASE Technologies, Inc.
00:30:0C	Congruency             # CONGRUENCY, LTD.
00:30:0D	MmcTechnol             # MMC Technology, Inc.
00:30:0E	KlotzDigit             # Klotz Digital AG
00:30:0F	Imt-Inform             # IMT - Information Management T
00:30:10	Visionetic             # VISIONETICS INTERNATIONAL
00:30:11	HmsFieldbu             # HMS FIELDBUS SYSTEMS AB
00:30:12	DigitalEng             # DIGITAL ENGINEERING LTD.
00:30:13	Nec                    # NEC Corporation
00:30:14	Divio                  # DIVIO, INC.
00:30:15	CpClare                # CP CLARE CORP.
00:30:16	Ishida                 # ISHIDA CO., LTD.
00:30:17	BluearcUk              # BlueArc UK Ltd
00:30:18	JetwayInfo             # Jetway Information Co., Ltd.
00:30:19	Cisco                  # CISCO SYSTEMS, INC.
00:30:1A	Smartbridg             # SMARTBRIDGES PTE. LTD.
00:30:1B	Shuttle                # SHUTTLE, INC.
00:30:1C	AltvaterAi             # ALTVATER AIRDATA SYSTEMS
00:30:1D	Skystream              # SKYSTREAM, INC.
00:30:1E	3comEurope             # 3COM Europe Ltd.
00:30:1F	OpticalNet             # OPTICAL NETWORKS, INC.
00:30:20	Tsi                    # TSI, Inc..
00:30:21	HsingTechE             # HSING TECH. ENTERPRISE CO.,LTD
00:30:22	FongKaiInd             # Fong Kai Industrial Co., Ltd.
00:30:23	CogentComp             # COGENT COMPUTER SYSTEMS, INC.
00:30:24	Cisco                  # CISCO SYSTEMS, INC.
00:30:25	CheckoutCo             # CHECKOUT COMPUTER SYSTEMS, LTD
00:30:26	HeitelDigi             # HeiTel Digital Video GmbH
00:30:27	Kerbango               # KERBANGO, INC.
00:30:28	FaseSaldat             # FASE Saldatura srl
00:30:29	Opicom
00:30:2A	SouthernIn             # SOUTHERN INFORMATION
00:30:2B	InalpNetwo             # INALP NETWORKS, INC.
00:30:2C	Sylantro               # SYLANTRO SYSTEMS CORPORATION
00:30:2D	QuantumBri             # QUANTUM BRIDGE COMMUNICATIONS
00:30:2E	HoftWessel             # Hoft & Wessel AG
00:30:2F	SmithsIndu             # Smiths Industries
00:30:30	Harmonix               # HARMONIX CORPORATION
00:30:31	LightwaveC             # LIGHTWAVE COMMUNICATIONS, INC.
00:30:32	Magicram               # MagicRam, Inc.
00:30:33	OrientTele             # ORIENT TELECOM CO., LTD.
00:30:34	SetEnginee             # SET ENGINEERING
00:30:35	Corning                # Corning Incorporated
00:30:36	RmpElektro             # RMP ELEKTRONIKSYSTEME GMBH
00:30:37	PackardBel             # Packard Bell Nec Services
00:30:38	Xcp                    # XCP, INC.
00:30:39	SoftbookPr             # SOFTBOOK PRESS
00:30:3A	Maatel
00:30:3B	PowercomTe             # PowerCom Technology
00:30:3C	Onnto                  # ONNTO CORP.
00:30:3D	Iva                    # IVA CORPORATION
00:30:3E	Radcom                 # Radcom Ltd.
00:30:3F	TurbocommT             # TurboComm Tech Inc.
00:30:40	Cisco                  # CISCO SYSTEMS, INC.
00:30:41	SaejinTM               # SAEJIN T & M CO., LTD.
00:30:42	Detewe-Deu             # DeTeWe-Deutsche Telephonwerke
00:30:43	IdreamTech             # IDREAM TECHNOLOGIES, PTE. LTD.
00:30:44	PortsmithL             # Portsmith LLC
00:30:45	VillageNet             # Village Networks, Inc. (VNI)
00:30:46	Controlled             # Controlled Electronic Manageme
00:30:47	NisseiElec             # NISSEI ELECTRIC CO., LTD.
00:30:48	Supermicro             # Supermicro Computer, Inc.
00:30:49	BryantTech             # BRYANT TECHNOLOGY, LTD.
00:30:4A	Fraunhofer             # Fraunhofer IPMS
00:30:4B	Orbacom                # ORBACOM SYSTEMS, INC.
00:30:4C	AppianComm             # APPIAN COMMUNICATIONS, INC.
00:30:4D	Esi
00:30:4E	BustecProd             # BUSTEC PRODUCTION LTD.
00:30:4F	PlanetTech             # PLANET Technology Corporation
00:30:50	VersaTechn             # Versa Technology
00:30:51	OrbitAvion             # ORBIT AVIONIC & COMMUNICATION
00:30:52	ElasticNet             # ELASTIC NETWORKS
00:30:53	Basler                 # Basler AG
00:30:54	CastlenetT             # CASTLENET TECHNOLOGY, INC.
00:30:55	HitachiSem             # Hitachi Semiconductor America,
00:30:56	BeckIpc                # Beck IPC GmbH
00:30:57	Qtelnet                # QTelNet, Inc.
00:30:58	ApiMotion              # API MOTION
00:30:59	Digital-Lo             # DIGITAL-LOGIC AG
00:30:5A	Telgen                 # TELGEN CORPORATION
00:30:5B	ModuleDepa             # MODULE DEPARTMENT
00:30:5C	SmarLabora             # SMAR Laboratories Corp.
00:30:5D	Digitra                # DIGITRA SYSTEMS, INC.
00:30:5E	AbelkoInno             # Abelko Innovation
00:30:5F	ImaconAps              # IMACON APS
00:30:60	Powerfile              # Powerfile, Inc.
00:30:61	Mobytel
00:30:62	Path1Netwo             # PATH 1 NETWORK TECHNOL'S INC.
00:30:63	Santera                # SANTERA SYSTEMS, INC.
00:30:64	AdlinkTech             # ADLINK TECHNOLOGY, INC.
00:30:65	AppleCompu             # APPLE COMPUTER, INC.
00:30:66	DigitalWir             # DIGITAL WIRELESS CORPORATION
00:30:67	BiostarMic             # BIOSTAR MICROTECH INT'L CORP.
00:30:68	Cybernetic             # CYBERNETICS TECH. CO., LTD.
00:30:69	ImpacctTec             # IMPACCT TECHNOLOGY CORP.
00:30:6A	PentaMedia             # PENTA MEDIA CO., LTD.
00:30:6B	Cmos                   # CMOS SYSTEMS, INC.
00:30:6C	HitexHoldi             # Hitex Holding GmbH
00:30:6D	LucentTech             # LUCENT TECHNOLOGIES
00:30:6E	HewlettPac             # HEWLETT PACKARD
00:30:6F	SeyeonTech             # SEYEON TECH. CO., LTD.
00:30:70	1net                   # 1Net Corporation
00:30:71	Cisco                  # Cisco Systems, Inc.
00:30:72	Intellibyt             # INTELLIBYTE INC.
00:30:73	Internatio             # International Microsystems, In
00:30:74	Equiinet               # EQUIINET LTD.
00:30:75	Adtech
00:30:76	Akamba                 # Akamba Corporation
00:30:77	OnpremNetw             # ONPREM NETWORKS
00:30:78	Cisco                  # Cisco Systems, Inc.
00:30:79	Cqos                   # CQOS, INC.
00:30:7A	AdvancedTe             # Advanced Technology & Systems
00:30:7B	Cisco                  # Cisco Systems, Inc.
00:30:7C	AdidSa                 # ADID SA
00:30:7D	GreAmerica             # GRE AMERICA, INC.
00:30:7E	RedflexCom             # Redflex Communication Systems
00:30:7F	Irlan                  # IRLAN LTD.
00:30:80	Cisco                  # CISCO SYSTEMS, INC.
00:30:81	AltosC&C               # ALTOS C&C
00:30:82	TaihanElec             # TAIHAN ELECTRIC WIRE CO., LTD.
00:30:83	Ivron                  # Ivron Systems
00:30:84	AlliedTele             # ALLIED TELESYN INTERNAIONAL
00:30:85	Cisco                  # CISCO SYSTEMS, INC.
00:30:86	Transistor             # Transistor Devices, Inc.
00:30:87	VegaGriesh             # VEGA GRIESHABER KG
00:30:88	Siara                  # Siara Systems, Inc.
00:30:89	Spectrapoi             # Spectrapoint Wireless, LLC
00:30:8A	NicotraSis             # NICOTRA SISTEMI S.P.A
00:30:8B	BrixNetwor             # Brix Networks
00:30:8C	AdvancedDi             # ADVANCED DIGITAL INFORMATION
00:30:8D	Pinnacle               # PINNACLE SYSTEMS, INC.
00:30:8E	CrossMatch             # CROSS MATCH TECHNOLOGIES, INC.
00:30:8F	Micrilor               # MICRILOR, Inc.
00:30:90	CyraTechno             # CYRA TECHNOLOGIES, INC.
00:30:91	TaiwanFirs             # TAIWAN FIRST LINE ELEC. CORP.
00:30:92	Modunorm               # ModuNORM GmbH
00:30:93	SonnetTech             # SONNET TECHNOLOGIES, INC.
00:30:94	Cisco                  # Cisco Systems, Inc.
00:30:95	ProcompInf             # Procomp Informatics, Ltd.
00:30:96	Cisco                  # CISCO SYSTEMS, INC.
00:30:97	Exomatic               # EXOMATIC AB
00:30:98	GlobalConv             # Global Converging Technologies
00:30:99	BoenigUndK             # BOENIG UND KALLENBACH OHG
00:30:9A	AstroTerra             # ASTRO TERRA CORP.
00:30:9B	Smartware
00:30:9C	TimingAppl             # Timing Applications, Inc.
00:30:9D	NimbleMicr             # Nimble Microsystems, Inc.
00:30:9E	Workbit                # WORKBIT CORPORATION.
00:30:9F	AmberNetwo             # AMBER NETWORKS
00:30:A0	TycoSubmar             # TYCO SUBMARINE SYSTEMS, LTD.
00:30:A1	Webgate                # WEBGATE Inc.
00:30:A2	LightnerEn             # Lightner Engineering
00:30:A3	Cisco                  # CISCO SYSTEMS, INC.
00:30:A4	WoodwindCo             # Woodwind Communications System
00:30:A5	ActivePowe             # ACTIVE POWER
00:30:A6	VianetTech             # VIANET TECHNOLOGIES, LTD.
00:30:A7	Schweitzer             # SCHWEITZER ENGINEERING
00:30:A8	OlECommuni             # OL'E COMMUNICATIONS, INC.
00:30:A9	Netiverse              # Netiverse, Inc.
00:30:AA	AxusMicros             # AXUS MICROSYSTEMS, INC.
00:30:AB	DeltaNetwo             # DELTA NETWORKS, INC.
00:30:AC	SystemeLau             # Systeme Lauer GmbH & Co., Ltd.
00:30:AD	ShanghaiCo             # SHANGHAI COMMUNICATION
00:30:AE	TimesNSyst             # Times N System, Inc.
00:30:AF	Honeywell              # Honeywell GmbH
00:30:B0	Convergene             # Convergenet Technologies
00:30:B1	Axess-ProN             # aXess-pro networks GmbH
00:30:B2	L-3SonomaE             # L-3 Sonoma EO
00:30:B3	SanValley              # San Valley Systems, Inc.
00:30:B4	Intersil               # INTERSIL CORP.
00:30:B5	TadiranMic             # Tadiran Microwave Networks
00:30:B6	Cisco                  # CISCO SYSTEMS, INC.
00:30:B7	Teletrol               # Teletrol Systems, Inc.
00:30:B8	Riverdelta             # RiverDelta Networks
00:30:B9	Ectel
00:30:BA	Ac&TSystem             # AC&T SYSTEM CO., LTD.
00:30:BB	Cacheflow              # CacheFlow, Inc.
00:30:BC	Optronic               # Optronic AG
00:30:BD	BelkinComp             # BELKIN COMPONENTS
00:30:BE	City-NetTe             # City-Net Technology, Inc.
00:30:BF	Multidata              # MULTIDATA GMBH
00:30:C0	LaraTechno             # Lara Technology, Inc.
00:30:C1	Hewlett-Pa             # HEWLETT-PACKARD
00:30:C2	Comone
00:30:C3	Flueckiger             # FLUECKIGER ELEKTRONIK AG
00:30:C4	CanonImagi             # Canon Imaging System Technologies, Inc.
00:30:C5	CadenceDes             # CADENCE DESIGN SYSTEMS
00:30:C6	ControlSol             # CONTROL SOLUTIONS, INC.
00:30:C7	Macromate              # MACROMATE CORP.
00:30:C8	GadLine                # GAD LINE, LTD.
00:30:C9	LuxnN                  # LuxN, N
00:30:CA	DiscoveryC             # Discovery Com
00:30:CB	OmniFlowCo             # OMNI FLOW COMPUTERS, INC.
00:30:CC	TenorNetwo             # Tenor Networks, Inc.
00:30:CD	Conexant               # CONEXANT SYSTEMS, INC.
00:30:CE	Zaffire
00:30:CF	TwoTechnol             # TWO TECHNOLOGIES, INC.
00:30:D0	Tellabs
00:30:D1	Inova                  # INOVA CORPORATION
00:30:D2	WinTechnol             # WIN TECHNOLOGIES, CO., LTD.
00:30:D3	AgilentTec             # Agilent Technologies
00:30:D4	Aae                    # AAE Systems, Inc
00:30:D5	Dresearch              # DResearch GmbH
00:30:D6	MscVertrie             # MSC VERTRIEBS GMBH
00:30:D7	Innovative             # Innovative Systems, L.L.C.
00:30:D8	Sitek
00:30:D9	DatacoreSo             # DATACORE SOFTWARE CORP.
00:30:DA	Comtrend               # COMTREND CO.
00:30:DB	MindreadyS             # Mindready Solutions, Inc.
00:30:DC	Rightech               # RIGHTECH CORPORATION
00:30:DD	Indigita               # INDIGITA CORPORATION
00:30:DE	WagoKontak             # WAGO Kontakttechnik GmbH
00:30:DF	Kb/TelTele             # KB/TEL TELECOMUNICACIONES
00:30:E0	OxfordSemi             # OXFORD SEMICONDUCTOR LTD.
00:30:E1	Acrotron               # ACROTRON SYSTEMS, INC.
00:30:E2	Garnet                 # GARNET SYSTEMS CO., LTD.
00:30:E3	SedonaNetw             # SEDONA NETWORKS CORP.
00:30:E4	ChiyodaSys             # CHIYODA SYSTEM RIKEN
00:30:E5	AmperDatos             # Amper Datos S.A.
00:30:E6	SiemensMed             # SIEMENS MEDICAL SYSTEMS
00:30:E7	CnfMobileS             # CNF MOBILE SOLUTIONS, INC.
00:30:E8	Ensim                  # ENSIM CORP.
00:30:E9	GmaCommuni             # GMA COMMUNICATION MANUFACT'G
00:30:EA	TeraforceT             # TeraForce Technology Corporation
00:30:EB	TurbonetCo             # TURBONET COMMUNICATIONS, INC.
00:30:EC	Borgardt
00:30:ED	ExpertMagn             # Expert Magnetics Corp.
00:30:EE	DsgTechnol             # DSG Technology, Inc.
00:30:EF	NeonTechno             # NEON TECHNOLOGY, INC.
00:30:F0	UniformInd             # Uniform Industrial Corp.
00:30:F1	AcctonTech             # Accton Technology Corp.
00:30:F2	Cisco                  # CISCO SYSTEMS, INC.
00:30:F3	AtWorkComp             # At Work Computers
00:30:F4	StardotTec             # STARDOT TECHNOLOGIES
00:30:F5	WildLab                # Wild Lab. Ltd.
00:30:F6	Securelogi             # SECURELOGIX CORPORATION
00:30:F7	Ramix                  # RAMIX INC.
00:30:F8	Dynapro                # Dynapro Systems, Inc.
00:30:F9	Sollae                 # Sollae Systems Co., Ltd.
00:30:FA	Telica                 # TELICA, INC.
00:30:FB	AzsTechnol             # AZS Technology AG
00:30:FC	TerawaveCo             # Terawave Communications, Inc.
00:30:FD	Integrated             # INTEGRATED SYSTEMS DESIGN
00:30:FE	Dsa                    # DSA GmbH
00:30:FF	Datafab                # DATAFAB SYSTEMS, INC.
00:40:00	PciCompone             # PCI COMPONENTES DA AMZONIA LTD
00:40:01	ZyxelCommu             # ZYXEL COMMUNICATIONS, INC.
00:40:02	Perle                  # PERLE SYSTEMS LIMITED
00:40:03	EmersonPro             # Emerson Process Management Power & Water Solutions, Inc.
00:40:04	Icm                    # ICM CO. LTD.
00:40:05	AniCommuni             # ANI COMMUNICATIONS INC.
00:40:06	SampoTechn             # SAMPO TECHNOLOGY CORPORATION
00:40:07	TelmatInfo             # TELMAT INFORMATIQUE
00:40:08	APlusInfo              # A PLUS INFO CORPORATION
00:40:09	TachibanaT             # TACHIBANA TECTRON CO., LTD.
00:40:0A	PivotalTec             # PIVOTAL TECHNOLOGIES, INC.
00:40:0B	Cresc
00:40:0C	GeneralMic             # GENERAL MICRO SYSTEMS, INC.
00:40:0D	LannetData             # LANNET DATA COMMUNICATIONS,LTD
00:40:0E	MemotecCom             # MEMOTEC COMMUNICATIONS, INC.
00:40:0F	DatacomTec             # DATACOM TECHNOLOGIES
00:40:10	Sonic                  # SONIC SYSTEMS, INC.
00:40:11	AndoverCon             # ANDOVER CONTROLS CORPORATION
00:40:12	Windata                # WINDATA, INC.
00:40:13	NttDataCom             # NTT DATA COMM. SYSTEMS CORP.
00:40:14	Comsoft                # COMSOFT GMBH
00:40:15	AscomInfra             # ASCOM INFRASYS AG
00:40:16	HadaxElect             # HADAX ELECTRONICS, INC.
00:40:17	SilexTechn             # Silex Technology America
00:40:18	Adobe                  # ADOBE SYSTEMS, INC.
00:40:19	Aeon                   # AEON SYSTEMS, INC.
00:40:1A	FujiElectr             # FUJI ELECTRIC CO., LTD.
00:40:1B	Printer                # PRINTER SYSTEMS CORP.
00:40:1C	AstResearc             # AST RESEARCH, INC.
00:40:1D	InvisibleS             # INVISIBLE SOFTWARE, INC.
00:40:1E	Icc
00:40:1F	Colorgraph             # COLORGRAPH LTD
00:40:20	PinaclComm             # PINACL COMMUNICATION
00:40:21	RasterGrap             # RASTER GRAPHICS
00:40:22	KleverComp             # KLEVER COMPUTERS, INC.
00:40:23	Logic                  # LOGIC CORPORATION
00:40:24	Compac                 # COMPAC INC.
00:40:25	MolecularD             # MOLECULAR DYNAMICS
00:40:26	Melco                  # MELCO, INC.
00:40:27	SmcMassach             # SMC MASSACHUSETTS, INC.
00:40:28	Netcomm                # NETCOMM LIMITED
00:40:29	Compex
00:40:2A	Canoga-Per             # CANOGA-PERKINS
00:40:2B	TrigemComp             # TRIGEM COMPUTER, INC.
00:40:2C	IsisDistri             # ISIS DISTRIBUTED SYSTEMS, INC.
00:40:2D	HarrisAdac             # HARRIS ADACOM CORPORATION
00:40:2E	PrecisionS             # PRECISION SOFTWARE, INC.
00:40:2F	XlntDesign             # XLNT DESIGNS INC.
00:40:30	GkComputer             # GK COMPUTER
00:40:31	KokusaiEle             # KOKUSAI ELECTRIC CO., LTD
00:40:32	DigitalCom             # DIGITAL COMMUNICATIONS
00:40:33	AddtronTec             # ADDTRON TECHNOLOGY CO., LTD.
00:40:34	Bustek                 # BUSTEK CORPORATION
00:40:35	Opcom
00:40:36	TribeCompu             # TRIBE COMPUTER WORKS, INC.
00:40:37	Sea-Ilan               # SEA-ILAN, INC.
00:40:38	TalentElec             # TALENT ELECTRIC INCORPORATED
00:40:39	OptecDaiic             # OPTEC DAIICHI DENKO CO., LTD.
00:40:3A	ImpactTech             # IMPACT TECHNOLOGIES
00:40:3B	SynerjetIn             # SYNERJET INTERNATIONAL CORP.
00:40:3C	Forks                  # FORKS, INC.
00:40:3D	Teradata
00:40:3E	RasterOps              # RASTER OPS CORPORATION
00:40:3F	SsangyongC             # SSANGYONG COMPUTER SYSTEMS
00:40:40	RingAccess             # RING ACCESS, INC.
00:40:41	Fujikura               # FUJIKURA LTD.
00:40:42	NAT                    # N.A.T. GMBH
00:40:43	NokiaTelec             # NOKIA TELECOMMUNICATIONS
00:40:44	QnixComput             # QNIX COMPUTER CO., LTD.
00:40:45	Twinhead               # TWINHEAD CORPORATION
00:40:46	UdcResearc             # UDC RESEARCH LIMITED
00:40:47	WindRiver              # WIND RIVER SYSTEMS
00:40:48	SmdInforma             # SMD INFORMATICA S.A.
00:40:49	Tegimenta              # TEGIMENTA AG
00:40:4A	WestAustra             # WEST AUSTRALIAN DEPARTMENT
00:40:4B	MapleCompu             # MAPLE COMPUTER SYSTEMS
00:40:4C	HypertecPt             # HYPERTEC PTY LTD.
00:40:4D	Telecommun             # TELECOMMUNICATIONS TECHNIQUES
00:40:4E	Fluent                 # FLUENT, INC.
00:40:4F	SpaceNaval             # SPACE & NAVAL WARFARE SYSTEMS
00:40:50	Ironics                # IRONICS, INCORPORATED
00:40:51	Gracilis               # GRACILIS, INC.
00:40:52	StarTechno             # STAR TECHNOLOGIES, INC.
00:40:53	AmproCompu             # AMPRO COMPUTERS
00:40:54	Connection             # CONNECTION MACHINES SERVICES
00:40:55	Metronix               # METRONIX GMBH
00:40:56	McmJapan               # MCM JAPAN LTD.
00:40:57	Lockheed-S             # LOCKHEED - SANDERS
00:40:58	Kronos                 # KRONOS, INC.
00:40:59	YoshidaKog             # YOSHIDA KOGYO K. K.
00:40:5A	GoldstarIn             # GOLDSTAR INFORMATION & COMM.
00:40:5B	Funasset               # FUNASSET LIMITED
00:40:5C	Future                 # FUTURE SYSTEMS, INC.
00:40:5D	Star-Tek               # STAR-TEK, INC.
00:40:5E	NorthHills             # NORTH HILLS ISRAEL
00:40:5F	AfeCompute             # AFE COMPUTERS LTD.
00:40:60	Comendec               # COMENDEC LTD
00:40:61	DatatechEn             # DATATECH ENTERPRISES CO., LTD.
00:40:62	E-Systems/             # E-SYSTEMS, INC./GARLAND DIV.
00:40:63	ViaTechnol             # VIA TECHNOLOGIES, INC.
00:40:64	KlaInstrum             # KLA INSTRUMENTS CORPORATION
00:40:65	GteSpacene             # GTE SPACENET
00:40:66	HitachiCab             # HITACHI CABLE, LTD.
00:40:67	Omnibyte               # OMNIBYTE CORPORATION
00:40:68	Extended               # EXTENDED SYSTEMS
00:40:69	Lemcom                 # LEMCOM SYSTEMS, INC.
00:40:6A	KentekInfo             # KENTEK INFORMATION SYSTEMS,INC
00:40:6B	Sysgen
00:40:6C	Copernique
00:40:6D	Lanco                  # LANCO, INC.
00:40:6E	Corollary              # COROLLARY, INC.
00:40:6F	SyncResear             # SYNC RESEARCH INC.
00:40:70	Interware              # INTERWARE CO., LTD.
00:40:71	AtmCompute             # ATM COMPUTER GMBH
00:40:72	AppliedInn             # Applied Innovation Inc.
00:40:73	BassAssoci             # BASS ASSOCIATES
00:40:74	CableAndWi             # CABLE AND WIRELESS
00:40:75	M-TradeUk              # M-TRADE (UK) LTD
00:40:76	SunConvers             # Sun Conversion Technologies
00:40:77	MaxtonTech             # MAXTON TECHNOLOGY CORPORATION
00:40:78	WearnesAut             # WEARNES AUTOMATION PTE LTD
00:40:79	JukoManufa             # JUKO MANUFACTURE COMPANY, LTD.
00:40:7A	SocieteDEx             # SOCIETE D'EXPLOITATION DU CNIT
00:40:7B	Scientific             # SCIENTIFIC ATLANTA
00:40:7C	Qume                   # QUME CORPORATION
00:40:7D	ExtensionT             # EXTENSION TECHNOLOGY CORP.
00:40:7E	Evergreen              # EVERGREEN SYSTEMS, INC.
00:40:7F	Flir                   # FLIR Systems
00:40:80	Athenix                # ATHENIX CORPORATION
00:40:81	Mannesmann             # MANNESMANN SCANGRAPHIC GMBH
00:40:82	Laboratory             # LABORATORY EQUIPMENT CORP.
00:40:83	TdaIndustr             # TDA INDUSTRIA DE PRODUTOS
00:40:84	Honeywell              # HONEYWELL INC.
00:40:85	SaabInstru             # SAAB INSTRUMENTS AB
00:40:86	MichelsKle             # MICHELS & KLEBERHOFF COMPUTER
00:40:87	Ubitrex                # UBITREX CORPORATION
00:40:88	MobiusTech             # MOBIUS TECHNOLOGIES, INC.
00:40:89	Meidensha              # MEIDENSHA CORPORATION
00:40:8A	TpsTelepro             # TPS TELEPROCESSING SYS. GMBH
00:40:8B	Raylan                 # RAYLAN CORPORATION
00:40:8C	AxisCommun             # AXIS COMMUNICATIONS AB
00:40:8D	GoodyearTi             # THE GOODYEAR TIRE & RUBBER CO.
00:40:8E	Digilog                # DIGILOG, INC.
00:40:8F	Wm-DataMin             # WM-DATA MINFO AB
00:40:90	AnselCommu             # ANSEL COMMUNICATIONS
00:40:91	ProcompInd             # PROCOMP INDUSTRIA ELETRONICA
00:40:92	AspCompute             # ASP COMPUTER PRODUCTS, INC.
00:40:93	PaxdataNet             # PAXDATA NETWORKS LTD.
00:40:94	Shographic             # SHOGRAPHICS, INC.
00:40:95	RPTIntergr             # R.P.T. INTERGROUPS INT'L LTD.
00:40:96	Aironet			# Cisco Systems, Inc.
00:40:97	DatexDivis             # DATEX DIVISION OF
00:40:98	Dressler               # DRESSLER GMBH & CO.
00:40:99	Newgen                 # NEWGEN SYSTEMS CORP.
00:40:9A	NetworkExp             # NETWORK EXPRESS, INC.
00:40:9B	HalCompute             # HAL COMPUTER SYSTEMS INC.
00:40:9C	Transware
00:40:9D	Digiboard              # DIGIBOARD, INC.
00:40:9E	Concurrent             # CONCURRENT TECHNOLOGIES  LTD.
00:40:9F	Lancast/Ca             # LANCAST/CASAT TECHNOLOGY, INC.
00:40:A0	Goldstar               # GOLDSTAR CO., LTD.
00:40:A1	ErgoComput             # ERGO COMPUTING
00:40:A2	KingstarTe             # KINGSTAR TECHNOLOGY INC.
00:40:A3	Microunity             # MICROUNITY SYSTEMS ENGINEERING
00:40:A4	RoseElectr             # ROSE ELECTRONICS
00:40:A5	ClinicompI             # CLINICOMP INTL.
00:40:A6	Cray                   # Cray, Inc.
00:40:A7	ItautecPhi             # ITAUTEC PHILCO S.A.
00:40:A8	ImfInterna             # IMF INTERNATIONAL LTD.
00:40:A9	Datacom                # DATACOM INC.
00:40:AA	ValmetAuto             # VALMET AUTOMATION INC.
00:40:AB	RolandDg               # ROLAND DG CORPORATION
00:40:AC	SuperWorks             # SUPER WORKSTATION, INC.
00:40:AD	SmaRegelsy             # SMA REGELSYSTEME GMBH
00:40:AE	DeltaContr             # DELTA CONTROLS, INC.
00:40:AF	DigitalPro             # DIGITAL PRODUCTS, INC.
00:40:B0	BytexEngin             # BYTEX CORPORATION, ENGINEERING
00:40:B1	Codonics               # CODONICS INC.
00:40:B2	Systemfors             # SYSTEMFORSCHUNG
00:40:B3	ParMicrosy             # PAR MICROSYSTEMS CORPORATION
00:40:B4	NextcomKK              # NEXTCOM K.K.
00:40:B5	VideoTechn             # VIDEO TECHNOLOGY COMPUTERS LTD
00:40:B6	Computerm              # COMPUTERM  CORPORATION
00:40:B7	StealthCom             # STEALTH COMPUTER SYSTEMS
00:40:B8	IdeaAssoci             # IDEA ASSOCIATES
00:40:B9	MacqElectr             # MACQ ELECTRONIQUE SA
00:40:BA	AlliantCom             # ALLIANT COMPUTER SYSTEMS CORP.
00:40:BB	GoldstarCa             # GOLDSTAR CABLE CO., LTD.
00:40:BC	Algorithmi             # ALGORITHMICS LTD.
00:40:BD	StarlightN             # STARLIGHT NETWORKS, INC.
00:40:BE	BoeingDefe             # BOEING DEFENSE & SPACE
00:40:BF	ChannelInt             # CHANNEL SYSTEMS INTERN'L INC.
00:40:C0	VistaContr             # VISTA CONTROLS CORPORATION
00:40:C1	Bizerba-We             # BIZERBA-WERKE WILHEIM KRAUT
00:40:C2	AppliedCom             # APPLIED COMPUTING DEVICES
00:40:C3	FischerAnd             # FISCHER AND PORTER CO.
00:40:C4	KinkeiSyst             # KINKEI SYSTEM CORPORATION
00:40:C5	MicomCommu             # MICOM COMMUNICATIONS INC.
00:40:C6	FibernetRe             # FIBERNET RESEARCH, INC.
00:40:C7	RubyTech               # RUBY TECH CORPORATION
00:40:C8	MilanTechn             # MILAN TECHNOLOGY CORPORATION
00:40:C9	Ncube
00:40:CA	FirstInter             # FIRST INTERNAT'L COMPUTER, INC
00:40:CB	LanwanTech             # LANWAN TECHNOLOGIES
00:40:CC	SilcomManu             # SILCOM MANUF'G TECHNOLOGY INC.
00:40:CD	TeraMicros             # TERA MICROSYSTEMS, INC.
00:40:CE	Net-Source             # NET-SOURCE, INC.
00:40:CF	Strawberry             # STRAWBERRY TREE, INC.
00:40:D0	MitacInter             # MITAC INTERNATIONAL CORP.
00:40:D1	FukudaDens             # FUKUDA DENSHI CO., LTD.
00:40:D2	Pagine                 # PAGINE CORPORATION
00:40:D3	KimpsionIn             # KIMPSION INTERNATIONAL CORP.
00:40:D4	GageTalker             # GAGE TALKER CORP.
00:40:D5	Sartorius              # SARTORIUS AG
00:40:D6	Locamation             # LOCAMATION B.V.
00:40:D7	StudioGen              # STUDIO GEN INC.
00:40:D8	OceanOffic             # OCEAN OFFICE AUTOMATION LTD.
00:40:D9	AmericanMe             # AMERICAN MEGATRENDS INC.
00:40:DA	Telspec                # TELSPEC LTD
00:40:DB	AdvancedTe             # ADVANCED TECHNICAL SOLUTIONS
00:40:DC	TritecElec             # TRITEC ELECTRONIC GMBH
00:40:DD	HongTechno             # HONG TECHNOLOGIES
00:40:DE	Elettronic             # ELETTRONICA SAN GIORGIO
00:40:DF	Digalog                # DIGALOG SYSTEMS, INC.
00:40:E0	Atomwide               # ATOMWIDE LTD.
00:40:E1	MarnerInte             # MARNER INTERNATIONAL, INC.
00:40:E2	MesaRidgeT             # MESA RIDGE TECHNOLOGIES, INC.
00:40:E3	Quin                   # QUIN SYSTEMS LTD
00:40:E4	E-MTechnol             # E-M TECHNOLOGY, INC.
00:40:E5	Sybus                  # SYBUS CORPORATION
00:40:E6	CAEN                   # C.A.E.N.
00:40:E7	ArnosInstr             # ARNOS INSTRUMENTS & COMPUTER
00:40:E8	CharlesRiv             # CHARLES RIVER DATA SYSTEMS,INC
00:40:E9	Accord                 # ACCORD SYSTEMS, INC.
00:40:EA	PlainTree              # PLAIN TREE SYSTEMS INC
00:40:EB	MartinMari             # MARTIN MARIETTA CORPORATION
00:40:EC	MikasaSyst             # MIKASA SYSTEM ENGINEERING
00:40:ED	NetworkCon             # NETWORK CONTROLS INT'NATL INC.
00:40:EE	Optimem
00:40:EF	Hypercom               # HYPERCOM, INC.
00:40:F0	Micro                  # MICRO SYSTEMS, INC.
00:40:F1	ChuoElectr             # CHUO ELECTRONICS CO., LTD.
00:40:F2	JanichKlas             # JANICH & KLASS COMPUTERTECHNIK
00:40:F3	Netcor
00:40:F4	CameoCommu             # CAMEO COMMUNICATIONS, INC.
00:40:F5	OemEngines             # OEM ENGINES
00:40:F6	KatronComp             # KATRON COMPUTERS INC.
00:40:F7	PolaroidMe             # POLAROID MEDICAL IMAGING SYS.
00:40:F8	Systemhaus             # SYSTEMHAUS DISCOM
00:40:F9	Combinet
00:40:FA	Microboard             # MICROBOARDS, INC.
00:40:FB	CascadeCom             # CASCADE COMMUNICATIONS CORP.
00:40:FC	IbrCompute             # IBR COMPUTER TECHNIK GMBH
00:40:FD	Lxe
00:40:FE	SymplexCom             # SYMPLEX COMMUNICATIONS
00:40:FF	Telebit                # TELEBIT CORPORATION
00:42:52	RlxTechnol             # RLX Technologies
00:45:01	VersusTech             # Versus Technology, Inc.
00:48:54	DigitalSem             # Digital SemiConductor		21143/2 based 10/100
00:4F:49	Realtek
00:4F:4B	PineTechno             # Pine Technology Ltd.
00:50:00	NexoCommun             # NEXO COMMUNICATIONS, INC.
00:50:01	Yamashita              # YAMASHITA SYSTEMS CORP.
00:50:02	Omnisec                # OMNISEC AG
00:50:03	GretagMacb             # GRETAG MACBETH AG
00:50:04	3com                   # 3COM CORPORATION
00:50:06	Tac                    # TAC AB
00:50:07	SiemensTel             # SIEMENS TELECOMMUNICATION SYSTEMS LIMITED
00:50:08	TivaMicroc             # TIVA MICROCOMPUTER CORP. (TMC)
00:50:09	PhilipsBro             # PHILIPS BROADBAND NETWORKS
00:50:0A	IrisTechno             # IRIS TECHNOLOGIES, INC.
00:50:0B	Cisco                  # CISCO SYSTEMS, INC.
00:50:0C	E-TekLabs              # e-Tek Labs, Inc.
00:50:0D	SatoriElec             # SATORI ELECTORIC CO., LTD.
00:50:0E	ChromatisN             # CHROMATIS NETWORKS, INC.
00:50:0F	Cisco                  # CISCO SYSTEMS, INC.
00:50:10	NovanetLea             # NovaNET Learning, Inc.
00:50:12	Cbl-                   # CBL - GMBH
00:50:13	ChaparralN             # Chaparral Network Storage
00:50:14	Cisco                  # CISCO SYSTEMS, INC.
00:50:15	BrightStar             # BRIGHT STAR ENGINEERING
00:50:16	Sst/Woodhe             # SST/WOODHEAD INDUSTRIES
00:50:17	RsrSRL                 # RSR S.R.L.
00:50:18	Amit                   # AMIT, Inc.
00:50:19	SpringTide             # SPRING TIDE NETWORKS, INC.
00:50:1A	Uisiqn
00:50:1B	AblCanada              # ABL CANADA, INC.
00:50:1C	Jatom                  # JATOM SYSTEMS, INC.
00:50:1E	MirandaTec             # Miranda Technologies, Inc.
00:50:1F	Mrg                    # MRG SYSTEMS, LTD.
00:50:20	Mediastar              # MEDIASTAR CO., LTD.
00:50:21	EisInterna             # EIS INTERNATIONAL, INC.
00:50:22	ZonetTechn             # ZONET TECHNOLOGY, INC.
00:50:23	PgDesignEl             # PG DESIGN ELECTRONICS, INC.
00:50:24	Navic                  # NAVIC SYSTEMS, INC.
00:50:26	Cosystems              # COSYSTEMS, INC.
00:50:27	Genicom                # GENICOM CORPORATION
00:50:28	AvalCommun             # AVAL COMMUNICATIONS
00:50:29	1394Printe             # 1394 PRINTER WORKING GROUP
00:50:2A	Cisco                  # CISCO SYSTEMS, INC.
00:50:2B	Genrad                 # GENRAD LTD.
00:50:2C	SoyoComput             # SOYO COMPUTER, INC.
00:50:2D	Accel                  # ACCEL, INC.
00:50:2E	Cambex                 # CAMBEX CORPORATION
00:50:2F	Tollbridge             # TollBridge Technologies, Inc.
00:50:30	FuturePlus             # FUTURE PLUS SYSTEMS
00:50:31	AeroflexLa             # AEROFLEX LABORATORIES, INC.
00:50:32	PicazoComm             # PICAZO COMMUNICATIONS, INC.
00:50:33	MayanNetwo             # MAYAN NETWORKS
00:50:36	Netcam                 # NETCAM, LTD.
00:50:37	KogaElectr             # KOGA ELECTRONICS CO.
00:50:38	DainTeleco             # DAIN TELECOM CO., LTD.
00:50:39	MarinerNet             # MARINER NETWORKS
00:50:3A	DatongElec             # DATONG ELECTRONICS LTD.
00:50:3B	Mediafire              # MEDIAFIRE CORPORATION
00:50:3C	TsinghuaNo             # TSINGHUA NOVEL ELECTRONICS
00:50:3E	Cisco                  # CISCO SYSTEMS, INC.
00:50:3F	AnchorGame             # ANCHOR GAMES
00:50:40	PanasonicE             # Panasonic Electric Works Laboratory of America, Inc./SLC Lab
00:50:41	CtxOptoEle             # CTX OPTO ELECTRONIC CORP.
00:50:42	SciManufac             # SCI MANUFACTURING SINGAPORE PTE, LTD.
00:50:43	MarvellSem             # MARVELL SEMICONDUCTOR, INC.
00:50:44	Asaca                  # ASACA CORPORATION
00:50:45	RioworksSo             # RIOWORKS SOLUTIONS, INC.
00:50:46	MenicxInte             # MENICX INTERNATIONAL CO., LTD.
00:50:47	Private
00:50:48	Infolibria
00:50:49	EllacoyaNe             # ELLACOYA NETWORKS, INC.
00:50:4A	EltecoAS               # ELTECO A.S.
00:50:4B	BarconetNV             # BARCONET N.V.
00:50:4C	GalilMotio             # GALIL MOTION CONTROL, INC.
00:50:4D	TokyoElect             # TOKYO ELECTRON DEVICE LTD.
00:50:4E	SierraMoni             # SIERRA MONITOR CORP.
00:50:4F	OlencomEle             # OLENCOM ELECTRONICS
00:50:50	Cisco                  # CISCO SYSTEMS, INC.
00:50:51	IwatsuElec             # IWATSU ELECTRIC CO., LTD.
00:50:52	TiaraNetwo             # TIARA NETWORKS, INC.
00:50:53	Cisco                  # CISCO SYSTEMS, INC.
00:50:54	Cisco                  # CISCO SYSTEMS, INC.
00:50:55	Doms                   # DOMS A/S
00:50:56	Vmware                 # VMWare, Inc.
00:50:57	BroadbandA             # BROADBAND ACCESS SYSTEMS
00:50:58	Vegastream             # VegaStream Limted
00:50:59	Ibahn
00:50:5A	NetworkAlc             # NETWORK ALCHEMY, INC.
00:50:5B	KawasakiLs             # KAWASAKI LSI U.S.A., INC.
00:50:5C	Tundo                  # TUNDO CORPORATION
00:50:5E	DigitekMic             # DIGITEK MICROLOGIC S.A.
00:50:5F	BrandInnov             # BRAND INNOVATORS
00:50:60	TandbergTe             # TANDBERG TELECOM AS
00:50:62	KouwellEle             # KOUWELL ELECTRONICS CORP.  **
00:50:63	OyComselSy             # OY COMSEL SYSTEM AB
00:50:64	CaeElectro             # CAE ELECTRONICS
00:50:65	Densei-Lam             # DENSEI-LAMBAD Co., Ltd.
00:50:66	AtecomAdva             # AtecoM GmbH advanced telecomunication modules
00:50:67	Aerocomm               # AEROCOMM, INC.
00:50:68	Electronic             # ELECTRONIC INDUSTRIES ASSOCIATION
00:50:69	Pixstream              # PixStream Incorporated
00:50:6A	Edeva                  # EDEVA, INC.
00:50:6B	Spx-Ateg
00:50:6C	GLBeijerEl             # G & L BEIJER ELECTRONICS AB
00:50:6D	Videojet               # VIDEOJET SYSTEMS
00:50:6E	CorderEngi             # CORDER ENGINEERING CORPORATION
00:50:6F	G-Connect
00:50:70	ChaintechC             # CHAINTECH COMPUTER CO., LTD.
00:50:71	Aiwa                   # AIWA CO., LTD.
00:50:72	Corvis                 # CORVIS CORPORATION
00:50:73	Cisco                  # CISCO SYSTEMS, INC.
00:50:74	AdvancedHi             # ADVANCED HI-TECH CORP.
00:50:75	KestrelSol             # KESTREL SOLUTIONS
00:50:76	Ibm
00:50:77	ProlificTe             # PROLIFIC TECHNOLOGY, INC.
00:50:78	MegatonHou             # MEGATON HOUSE, LTD.
00:50:79	Private
00:50:7A	Xpeed                  # XPEED, INC.
00:50:7B	MerlotComm             # MERLOT COMMUNICATIONS
00:50:7C	Videocon               # VIDEOCON AG
00:50:7D	Ifp
00:50:7E	NewerTechn             # NEWER TECHNOLOGY
00:50:7F	Draytek                # DrayTek Corp.
00:50:80	Cisco                  # CISCO SYSTEMS, INC.
00:50:81	MurataMach             # MURATA MACHINERY, LTD.
00:50:82	Foresson               # FORESSON CORPORATION
00:50:83	Gilbarco               # GILBARCO, INC.
00:50:84	AtlProduct             # ATL PRODUCTS
00:50:86	TelkomSa               # TELKOM SA, LTD.
00:50:87	TerasakiEl             # TERASAKI ELECTRIC CO., LTD.
00:50:88	Amano                  # AMANO CORPORATION
00:50:89	SafetyMana             # SAFETY MANAGEMENT SYSTEMS
00:50:8B	CompaqComp             # COMPAQ COMPUTER CORPORATION
00:50:8C	Rsi                    # RSI SYSTEMS
00:50:8D	AbitComput             # ABIT COMPUTER CORPORATION
00:50:8E	Optimation             # OPTIMATION, INC.
00:50:8F	AsitaTechn             # ASITA TECHNOLOGIES INT'L LTD.
00:50:90	Dctri
00:50:91	Netaccess              # NETACCESS, INC.
00:50:92	RigakuIndu             # RIGAKU INDUSTRIAL CORPORATION
00:50:93	Boeing
00:50:94	PaceMicroT             # PACE MICRO TECHNOLOGY PLC
00:50:95	PeracomNet             # PERACOM NETWORKS
00:50:96	SalixTechn             # SALIX TECHNOLOGIES, INC.
00:50:97	Mmc-Embedd             # MMC-EMBEDDED COMPUTERTECHNIK GmbH
00:50:98	Globaloop              # GLOBALOOP, LTD.
00:50:99	3comEurope             # 3COM EUROPE, LTD.
00:50:9A	TagElectro             # TAG ELECTRONIC SYSTEMS
00:50:9B	Switchcore             # SWITCHCORE AB
00:50:9C	BetaResear             # BETA RESEARCH
00:50:9D	IndustreeB             # THE INDUSTREE B.V.
00:50:9E	LesTechnol             # Les Technologies SoftAcoustik Inc.
00:50:9F	HorizonCom             # HORIZON COMPUTER
00:50:A0	DeltaCompu             # DELTA COMPUTER SYSTEMS, INC.
00:50:A1	CarloGavaz             # CARLO GAVAZZI, INC.
00:50:A2	Cisco                  # CISCO SYSTEMS, INC.
00:50:A3	Transmedia             # TransMedia Communications, Inc.
00:50:A4	IoTech                 # IO TECH, INC.
00:50:A5	CapitolBus             # CAPITOL BUSINESS SYSTEMS, LTD.
00:50:A6	Optronics
00:50:A7	Cisco                  # CISCO SYSTEMS, INC.
00:50:A8	Opencon                # OpenCon Systems, Inc.
00:50:A9	MoldatWire             # MOLDAT WIRELESS TECHNOLGIES
00:50:AA	KonicaMino             # KONICA MINOLTA HOLDINGS, INC.
00:50:AB	Naltec                 # NALTEC, INC.
00:50:AC	MapleCompu             # MAPLE COMPUTER CORPORATION
00:50:AD	Communique             # CommUnique Wireless Corp.
00:50:AE	IwakiElect             # IWAKI ELECTRONICS CO., LTD.
00:50:AF	Intergon               # INTERGON, INC.
00:50:B0	Technology             # TECHNOLOGY ATLANTA CORPORATION
00:50:B1	GiddingsLe             # GIDDINGS & LEWIS
00:50:B2	BrodelAuto             # BRODEL AUTOMATION
00:50:B3	Voiceboard             # VOICEBOARD CORPORATION
00:50:B4	SatchwellC             # SATCHWELL CONTROL SYSTEMS, LTD
00:50:B5	Fichet-Bau             # FICHET-BAUCHE
00:50:B6	GoodWayInd             # GOOD WAY IND. CO., LTD.
00:50:B7	BoserTechn             # BOSER TECHNOLOGY CO., LTD.
00:50:B8	InovaCompu             # INOVA COMPUTERS GMBH & CO. KG
00:50:B9	XitronTech             # XITRON TECHNOLOGIES, INC.
00:50:BA	D-Link
00:50:BB	CmsTechnol             # CMS TECHNOLOGIES
00:50:BC	HammerStor             # HAMMER STORAGE SOLUTIONS
00:50:BD	Cisco                  # CISCO SYSTEMS, INC.
00:50:BE	FastMultim             # FAST MULTIMEDIA AG
00:50:BF	Mototech               # MOTOTECH INC.
00:50:C0	Gatan                  # GATAN, INC.
00:50:C1	GemflexNet             # GEMFLEX NETWORKS, LTD.
00:50:C2	IeeeRegist             # IEEE REGISTRATION AUTHORITY
00:50:C4	Imd
00:50:C5	AdsTechnol             # ADS TECHNOLOGIES, INC.
00:50:C6	LoopTeleco             # LOOP TELECOMMUNICATION INTERNATIONAL, INC.
00:50:C8	AddonicsCo             # ADDONICS COMMUNICATIONS, INC.
00:50:C9	MasproDenk             # MASPRO DENKOH CORP.
00:50:CA	NetToNetTe             # NET TO NET TECHNOLOGIES
00:50:CB	Jetter
00:50:CC	Xyratex
00:50:CD	Digianswer             # DIGIANSWER A/S
00:50:CE	LgInternat             # LG INTERNATIONAL CORP.
00:50:CF	VanlinkCom             # VANLINK COMMUNICATION TECHNOLOGY RESEARCH INSTITUTE
00:50:D0	Minerva                # MINERVA SYSTEMS
00:50:D1	Cisco                  # CISCO SYSTEMS, INC.
00:50:D2	CmcElectro             # CMC Electronics Inc
00:50:D3	DigitalAud             # DIGITAL AUDIO PROCESSING PTY. LTD.
00:50:D4	JoohongInf             # JOOHONG INFORMATION &
00:50:D5	Ad                     # AD SYSTEMS CORP.
00:50:D6	AtlasCopco             # ATLAS COPCO TOOLS AB
00:50:D7	Telstrat
00:50:D8	UnicornCom             # UNICORN COMPUTER CORP.
00:50:D9	Engetron-E             # ENGETRON-ENGENHARIA ELETRONICA IND. e COM. LTDA
00:50:DA	3com                   # 3COM CORPORATION
00:50:DB	Contempora             # CONTEMPORARY CONTROL
00:50:DC	TasTelefon             # TAS TELEFONBAU A. SCHWABE GMBH & CO. KG
00:50:DD	SerraSolda             # SERRA SOLDADURA, S.A.
00:50:DE	Signum                 # SIGNUM SYSTEMS CORP.
00:50:DF	Airfiber               # AirFiber, Inc.
00:50:E1	NsTechElec             # NS TECH ELECTRONICS SDN BHD
00:50:E2	Cisco                  # CISCO SYSTEMS, INC.
00:50:E3	TerayonCom             # Terayon Communications Systems
00:50:E4	AppleCompu             # APPLE COMPUTER, INC.
00:50:E6	Hakusan                # HAKUSAN CORPORATION
00:50:E7	ParadiseIn             # PARADISE INNOVATIONS (ASIA)
00:50:E8	Nomadix                # NOMADIX INC.
00:50:EA	XelCommuni             # XEL COMMUNICATIONS, INC.
00:50:EB	Alpha-Top              # ALPHA-TOP CORPORATION
00:50:EC	Olicom                 # OLICOM A/S
00:50:ED	AndaNetwor             # ANDA NETWORKS
00:50:EE	TekDigitel             # TEK DIGITEL CORPORATION
00:50:EF	SpeSystemh             # SPE Systemhaus GmbH
00:50:F0	Cisco                  # CISCO SYSTEMS, INC.
00:50:F1	LibitSigna             # LIBIT SIGNAL PROCESSING, LTD.
00:50:F2	Microsoft              # MICROSOFT CORP.
00:50:F3	GlobalNetI             # GLOBAL NET INFORMATION CO., Ltd.
00:50:F4	Sigmatek               # SIGMATEK GMBH & CO. KG
00:50:F6	Pan-Intern             # PAN-INTERNATIONAL INDUSTRIAL CORP.
00:50:F7	VentureMan             # VENTURE MANUFACTURING (SINGAPORE) LTD.
00:50:F8	EntregaTec             # ENTREGA TECHNOLOGIES, INC.
00:50:F9	Sensormati             # SENSORMATIC ACD
00:50:FA	Oxtel                  # OXTEL, LTD.
00:50:FB	VskElectro             # VSK ELECTRONICS
00:50:FC	EdimaxTech             # EDIMAX TECHNOLOGY CO., LTD.
00:50:FD	Visioncomm             # VISIONCOMM CO., LTD.
00:50:FE	PctvnetAsa             # PCTVnet ASA
00:50:FF	HakkoElect             # HAKKO ELECTRONICS CO., LTD.
00:55:00	Xerox
00:60:00	Xycom                  # XYCOM INC.
00:60:01	Innosys                # InnoSys, Inc.
00:60:02	ScreenSubt             # SCREEN SUBTITLING SYSTEMS, LTD
00:60:03	TeraokaWei             # TERAOKA WEIGH SYSTEM PTE, LTD.
00:60:04	Computador             # COMPUTADORES MODULARES SA
00:60:05	FeedbackDa             # FEEDBACK DATA LTD.
00:60:06	Sotec                  # SOTEC CO., LTD
00:60:07	AcresGamin             # ACRES GAMING, INC.
00:60:08	3com                   # 3COM CORPORATION
00:60:09	Cisco                  # CISCO SYSTEMS, INC.
00:60:0A	SordComput             # SORD COMPUTER CORPORATION
00:60:0B	Logware                # LOGWARE GmbH
00:60:0C	AppliedDat             # APPLIED DATA SYSTEMS, INC.
00:60:0D	DigitalLog             # Digital Logic GmbH
00:60:0E	WavenetInt             # WAVENET INTERNATIONAL, INC.
00:60:0F	Westell                # WESTELL, INC.
00:60:10	NetworkMac             # NETWORK MACHINES, INC.
00:60:11	CrystalSem             # CRYSTAL SEMICONDUCTOR CORP.
00:60:12	PowerCompu             # POWER COMPUTING CORPORATION
00:60:13	NetstalMas             # NETSTAL MASCHINEN AG
00:60:14	Edec                   # EDEC CO., LTD.
00:60:15	Net2net                # NET2NET CORPORATION
00:60:16	Clariion
00:60:17	Tokimec                # TOKIMEC INC.
00:60:18	StellarOne             # STELLAR ONE CORPORATION
00:60:19	RocheDiagn             # Roche Diagnostics
00:60:1A	KeithleyIn             # KEITHLEY INSTRUMENTS
00:60:1B	MesaElectr             # MESA ELECTRONICS
00:60:1C	Telxon                 # TELXON CORPORATION
00:60:1D	LucentTech             # LUCENT TECHNOLOGIES
00:60:1E	Softlab                # SOFTLAB, INC.
00:60:1F	StallionTe             # STALLION TECHNOLOGIES
00:60:20	PivotalNet             # PIVOTAL NETWORKING, INC.
00:60:21	Dsc                    # DSC CORPORATION
00:60:22	Vicom                  # VICOM SYSTEMS, INC.
00:60:23	PericomSem             # PERICOM SEMICONDUCTOR CORP.
00:60:24	GradientTe             # GRADIENT TECHNOLOGIES, INC.
00:60:25	ActiveImag             # ACTIVE IMAGING PLC
00:60:26	VikingComp             # VIKING COMPONENTS, INC.
00:60:27	SuperiorMo             # Superior Modular Products
00:60:28	Macrovisio             # MACROVISION CORPORATION
00:60:29	CaryPeriph             # CARY PERIPHERALS INC.
00:60:2A	SymicronCo             # SYMICRON COMPUTER COMMUNICATIONS, LTD.
00:60:2B	PeakAudio              # PEAK AUDIO
00:60:2C	LinxDataTe             # LINX Data Terminals, Inc.
00:60:2D	AlertonTec             # ALERTON TECHNOLOGIES, INC.
00:60:2E	Cyclades               # CYCLADES CORPORATION
00:60:2F	Cisco                  # CISCO SYSTEMS, INC.
00:60:30	VillageTro             # VILLAGE TRONIC ENTWICKLUNG
00:60:31	Hrk                    # HRK SYSTEMS
00:60:32	I-Cube                 # I-CUBE, INC.
00:60:33	AcuityImag             # ACUITY IMAGING, INC.
00:60:34	RobertBosc             # ROBERT BOSCH GmbH
00:60:35	DallasSemi             # DALLAS SEMICONDUCTOR, INC.
00:60:36	AustrianRe             # AUSTRIAN RESEARCH CENTER SEIBERSDORF
00:60:37	PhilipsSem             # PHILIPS SEMICONDUCTORS
00:60:38	NortelNetw             # Nortel Networks
00:60:39	SancomTech             # SanCom Technology, Inc.
00:60:3A	QuickContr             # QUICK CONTROLS LTD.
00:60:3B	AmtecSpa               # AMTEC spa
00:60:3C	HagiwaraSy             # HAGIWARA SYS-COM CO., LTD.
00:60:3D	3cx
00:60:3E	Cisco                  # CISCO SYSTEMS, INC.
00:60:3F	PatapscoDe             # PATAPSCO DESIGNS
00:60:40	Netro                  # NETRO CORP.
00:60:41	YokogawaEl             # Yokogawa Electric Corporation
00:60:42	TksUsa                 # TKS (USA), INC.
00:60:43	Comsoft                # ComSoft Systems, Inc.
00:60:44	Litton/Pol             # LITTON/POLY-SCIENTIFIC
00:60:45	PathlightT             # PATHLIGHT TECHNOLOGIES
00:60:46	Vmetro                 # VMETRO, INC.
00:60:47	Cisco                  # CISCO SYSTEMS, INC.
00:60:48	Emc                    # EMC CORPORATION
00:60:49	VinaTechno             # VINA TECHNOLOGIES
00:60:4A	SaicIdeasG             # SAIC IDEAS GROUP
00:60:4B	Safe-Com               # Safe-com GmbH & Co. KG
00:60:4C	SagemSa                # SAGEM SA
00:60:4D	MmcNetwork             # MMC NETWORKS, INC.
00:60:4E	CycleCompu             # CYCLE COMPUTER CORPORATION, INC.
00:60:4F	SuzukiMfg              # SUZUKI MFG. CO., LTD.
00:60:50	Internix               # INTERNIX INC.
00:60:51	QualitySem             # QUALITY SEMICONDUCTOR
00:60:52	Peripheral             # PERIPHERALS ENTERPRISE CO., Ltd.
00:60:53	ToyodaMach             # TOYODA MACHINE WORKS, LTD.
00:60:54	Controlwar             # CONTROLWARE GMBH
00:60:55	CornellUni             # CORNELL UNIVERSITY
00:60:56	NetworkToo             # NETWORK TOOLS, INC.
00:60:57	MurataManu             # MURATA MANUFACTURING CO., LTD.
00:60:58	CopperMoun             # COPPER MOUNTAIN COMMUNICATIONS, INC.
00:60:59	TechnicalC             # TECHNICAL COMMUNICATIONS CORP.
00:60:5A	Celcore                # CELCORE, INC.
00:60:5B	Intraserve             # IntraServer Technology, Inc.
00:60:5C	Cisco                  # CISCO SYSTEMS, INC.
00:60:5D	Scanivalve             # SCANIVALVE CORP.
00:60:5E	LibertyTec             # LIBERTY TECHNOLOGY NETWORKING
00:60:5F	NipponUnis             # NIPPON UNISOFT CORPORATION
00:60:60	DawningTec             # DAWNING TECHNOLOGIES, INC.
00:60:61	WhistleCom             # WHISTLE COMMUNICATIONS CORP.
00:60:62	Telesync               # TELESYNC, INC.
00:60:63	PsionDacom             # PSION DACOM PLC.
00:60:64	Netcomm                # NETCOMM LIMITED
00:60:65	BerneckerR             # BERNECKER & RAINER INDUSTRIE-ELEKTRONIC GmbH
00:60:66	LacroixTec             # LACROIX TECHNOLGIE
00:60:67	AcerNetxus             # ACER NETXUS INC.
00:60:68	EiconTechn             # EICON TECHNOLOGY CORPORATION
00:60:69	BrocadeCom             # BROCADE COMMUNICATIONS SYSTEMS, Inc.
00:60:6A	Mitsubishi             # MITSUBISHI WIRELESS COMMUNICATIONS. INC.
00:60:6B	Synclayer              # Synclayer Inc.
00:60:6C	Arescom
00:60:6D	DigitalEqu             # DIGITAL EQUIPMENT CORP.
00:60:6E	DavicomSem             # DAVICOM SEMICONDUCTOR, INC.
00:60:6F	ClarionOfA             # CLARION CORPORATION OF AMERICA
00:60:70	Cisco                  # CISCO SYSTEMS, INC.
00:60:71	MidasLab               # MIDAS LAB, INC.
00:60:72	VxlInstrum             # VXL INSTRUMENTS, LIMITED
00:60:73	RedcreekCo             # REDCREEK COMMUNICATIONS, INC.
00:60:74	QscAudioPr             # QSC AUDIO PRODUCTS
00:60:75	Pentek                 # PENTEK, INC.
00:60:76	Schlumberg             # SCHLUMBERGER TECHNOLOGIES RETAIL PETROLEUM SYSTEMS
00:60:77	PrisaNetwo             # PRISA NETWORKS
00:60:78	PowerMeasu             # POWER MEASUREMENT LTD.
00:60:79	Mainstream             # Mainstream Data, Inc.
00:60:7A	Dvs                    # DVS GmbH
00:60:7B	Fore                   # FORE SYSTEMS, INC.
00:60:7C	Waveaccess             # WaveAccess, Ltd.
00:60:7D	SentientNe             # SENTIENT NETWORKS INC.
00:60:7E	Gigalabs               # GIGALABS, INC.
00:60:7F	AuroraTech             # AURORA TECHNOLOGIES, INC.
00:60:80	Microtroni             # MICROTRONIX DATACOM LTD.
00:60:81	Tv/ComInte             # TV/COM INTERNATIONAL
00:60:82	NovalinkTe             # NOVALINK TECHNOLOGIES, INC.
00:60:83	Cisco                  # CISCO SYSTEMS, INC.
00:60:84	DigitalVid             # DIGITAL VIDEO
00:60:85	StorageCon             # Storage Concepts
00:60:86	LogicRepla             # LOGIC REPLACEMENT TECH. LTD.
00:60:87	KansaiElec             # KANSAI ELECTRIC CO., LTD.
00:60:88	WhiteMount             # WHITE MOUNTAIN DSP, INC.
00:60:89	Xata
00:60:8A	CitadelCom             # CITADEL COMPUTER
00:60:8B	Confertech             # ConferTech International
00:60:8C	3com                   # 3COM CORPORATION
00:60:8D	Unipulse               # UNIPULSE CORP.
00:60:8E	HeElectron             # HE ELECTRONICS, TECHNOLOGIE & SYSTEMTECHNIK GmbH
00:60:8F	TekramTech             # TEKRAM TECHNOLOGY CO., LTD.
00:60:90	AbleCommun             # ABLE COMMUNICATIONS, INC.
00:60:91	FirstPacif             # FIRST PACIFIC NETWORKS, INC.
00:60:92	Micro/Sys              # MICRO/SYS, INC.
00:60:93	Varian
00:60:94	Ibm                    # IBM CORP.
00:60:95	Accu-Time              # ACCU-TIME SYSTEMS, INC.
00:60:96	TSMicrotec             # T.S. MICROTECH INC.
00:60:97	3com                   # 3COM CORPORATION
00:60:98	HtCommunic             # HT COMMUNICATIONS
00:60:99	Sbe                    # SBE, Inc.
00:60:9A	NjkTechno              # NJK TECHNO CO.
00:60:9B	Astro-Med              # ASTRO-MED, INC.
00:60:9C	Perkin-Elm             # Perkin-Elmer Incorporated
00:60:9D	PmiFoodEqu             # PMI FOOD EQUIPMENT GROUP
00:60:9E	AscX3-Info             # ASC X3 - INFORMATION TECHNOLOGY STANDARDS SECRETARIATS
00:60:9F	Phast                  # PHAST CORPORATION
00:60:A0	SwitchedNe             # SWITCHED NETWORK TECHNOLOGIES, INC.
00:60:A1	Vpnet                  # VPNet, Inc.
00:60:A2	NihonUnisy             # NIHON UNISYS LIMITED CO.
00:60:A3	ContinuumT             # CONTINUUM TECHNOLOGY CORP.
00:60:A4	GrinakerSy             # GRINAKER SYSTEM TECHNOLOGIES
00:60:A5	Performanc             # PERFORMANCE TELECOM CORP.
00:60:A6	ParticleMe             # PARTICLE MEASURING SYSTEMS
00:60:A7	Microsens              # MICROSENS GmbH & CO. KG
00:60:A8	Tidomat                # TIDOMAT AB
00:60:A9	GesytecMbh             # GESYTEC MbH
00:60:AA	Intelligen             # INTELLIGENT DEVICES INC. (IDI)
00:60:AB	Larscom                # LARSCOM INCORPORATED
00:60:AC	Resilience             # RESILIENCE CORPORATION
00:60:AD	Megachips              # MegaChips Corporation
00:60:AE	TrioInform             # TRIO INFORMATION SYSTEMS AB
00:60:AF	PacificMic             # PACIFIC MICRO DATA, INC.
00:60:B0	HP
00:60:B1	Input/Outp             # INPUT/OUTPUT, INC.
00:60:B2	ProcessCon             # PROCESS CONTROL CORP.
00:60:B3	Z-Com                  # Z-COM, INC.
00:60:B4	GlenayreR&             # GLENAYRE R&D INC.
00:60:B5	Keba                   # KEBA GmbH
00:60:B6	LandComput             # LAND COMPUTER CO., LTD.
00:60:B7	Channelmat             # CHANNELMATIC, INC.
00:60:B8	Corelis                # CORELIS INC.
00:60:B9	Nitsuko                # NITSUKO CORPORATION
00:60:BA	SaharaNetw             # SAHARA NETWORKS, INC.
00:60:BB	Cabletron-             # CABLETRON - NETLINK, INC.
00:60:BC	KeunyoungE             # KeunYoung Electronics & Communication Co., Ltd.
00:60:BD	Hubbell-Pu             # HUBBELL-PULSECOM
00:60:BE	Webtronics
00:60:BF	Macraigor              # MACRAIGOR SYSTEMS, INC.
00:60:C0	NeraAs                 # NERA AS
00:60:C1	Wavespan               # WaveSpan Corporation
00:60:C2	Mpl                    # MPL AG
00:60:C3	Netvision              # NETVISION CORPORATION
00:60:C4	SolitonKK              # SOLITON SYSTEMS K.K.
00:60:C5	Ancot                  # ANCOT CORP.
00:60:C6	Dcs                    # DCS AG
00:60:C7	AmatiCommu             # AMATI COMMUNICATIONS CORP.
00:60:C8	KukaWeldin             # KUKA WELDING SYSTEMS & ROBOTS
00:60:C9	Controlnet             # ControlNet, Inc.
00:60:CA	Harmonic               # HARMONIC SYSTEMS INCORPORATED
00:60:CB	HitachiZos             # HITACHI ZOSEN CORPORATION
00:60:CC	Emtrak                 # EMTRAK, INCORPORATED
00:60:CD	Videoserve             # VideoServer, Inc.
00:60:CE	AcclaimCom             # ACCLAIM COMMUNICATIONS
00:60:CF	AlteonNetw             # ALTEON NETWORKS, INC.
00:60:D0	SnmpResear             # SNMP RESEARCH INCORPORATED
00:60:D1	CascadeCom             # CASCADE COMMUNICATIONS
00:60:D2	LucentTech             # LUCENT TECHNOLOGIES TAIWAN TELECOMMUNICATIONS CO., LTD.
00:60:D3	At&T
00:60:D4	EldatCommu             # ELDAT COMMUNICATION LTD.
00:60:D5	MiyachiTec             # MIYACHI TECHNOS CORP.
00:60:D6	NovatelWir             # NovAtel Wireless Technologies Ltd.
00:60:D7	EcolePolyt             # ECOLE POLYTECHNIQUE FEDERALE DE LAUSANNE (EPFL)
00:60:D8	Elmic                  # ELMIC SYSTEMS, INC.
00:60:D9	TransysNet             # TRANSYS NETWORKS INC.
00:60:DA	JbmElectro             # JBM ELECTRONICS CO.
00:60:DB	NtpElektro             # NTP ELEKTRONIK A/S
00:60:DC	ToyoNetwor             # Toyo Network Systems Co, Ltd.
00:60:DD	Myricom                # MYRICOM, INC.
00:60:DE	Kayser-Thr             # KAYSER-THREDE GmbH
00:60:DF	Cnt                    # CNT Corporation
00:60:E0	AxiomTechn             # AXIOM TECHNOLOGY CO., LTD.
00:60:E1	OrckitComm             # ORCKIT COMMUNICATIONS LTD.
00:60:E2	QuestEngin             # QUEST ENGINEERING & DEVELOPMENT
00:60:E3	ArbinInstr             # ARBIN INSTRUMENTS
00:60:E4	Compuserve             # COMPUSERVE, INC.
00:60:E5	FujiAutoma             # FUJI AUTOMATION CO., LTD.
00:60:E6	Shomiti                # SHOMITI SYSTEMS INCORPORATED
00:60:E7	Randata
00:60:E8	HitachiCom             # HITACHI COMPUTER PRODUCTS (AMERICA), INC.
00:60:E9	AtopTechno             # ATOP TECHNOLOGIES, INC.
00:60:EA	Streamlogi             # StreamLogic
00:60:EB	Fourthtrac             # FOURTHTRACK SYSTEMS
00:60:EC	HermaryOpt             # HERMARY OPTO ELECTRONICS INC.
00:60:ED	RicardoTes             # RICARDO TEST AUTOMATION LTD.
00:60:EE	Apollo
00:60:EF	FlytechTec             # FLYTECH TECHNOLOGY CO., LTD.
00:60:F0	JohnsonJoh             # JOHNSON & JOHNSON MEDICAL, INC
00:60:F1	ExpCompute             # EXP COMPUTER, INC.
00:60:F2	Lasergraph             # LASERGRAPHICS, INC.
00:60:F3	Performanc             # Performance Analysis Broadband, Spirent plc
00:60:F4	AdvancedCo             # ADVANCED COMPUTER SOLUTIONS, Inc.
00:60:F5	IconWest               # ICON WEST, INC.
00:60:F6	NextestCom             # NEXTEST COMMUNICATIONS PRODUCTS, INC.
00:60:F7	Datafusion             # DATAFUSION SYSTEMS
00:60:F8	LoranInter             # Loran International Technologies Inc.
00:60:F9	DiamondLan             # DIAMOND LANE COMMUNICATIONS
00:60:FA	Educationa             # EDUCATIONAL TECHNOLOGY RESOURCES, INC.
00:60:FB	Packeteer              # PACKETEER, INC.
00:60:FC	Conservati             # CONSERVATION THROUGH INNOVATION LTD.
00:60:FD	Netics                 # NetICs, Inc.
00:60:FE	LynxSystem             # LYNX SYSTEM DEVELOPERS, INC.
00:60:FF	Quvis                  # QuVis, Inc.
00:70:B0	M/A-ComCom             # M/A-COM INC. COMPANIES
00:70:B3	DataRecall             # DATA RECALL LTD.
00:80:00	Multitech              # MULTITECH SYSTEMS, INC.
00:80:01	Periphonic             # PERIPHONICS CORPORATION
00:80:02	SatelcomUk             # SATELCOM (UK) LTD
00:80:03	HytecElect             # HYTEC ELECTRONICS LTD.
00:80:04	AntlowComm             # ANTLOW COMMUNICATIONS, LTD.
00:80:05	CactusComp             # CACTUS COMPUTER INC.
00:80:06	Compuadd               # COMPUADD CORPORATION
00:80:07	DlogNc-Sys             # DLOG NC-SYSTEME
00:80:08	DynatechCo             # DYNATECH COMPUTER SYSTEMS
00:80:09	Jupiter                # JUPITER SYSTEMS, INC.
00:80:0A	JapanCompu             # JAPAN COMPUTER CORP.
00:80:0B	Csk                    # CSK CORPORATION
00:80:0C	Videcom                # VIDECOM LIMITED
00:80:0D	Vosswinkel             # VOSSWINKEL F.U.
00:80:0E	Atlantix               # ATLANTIX CORPORATION
00:80:0F	SMC
00:80:10	CommodoreI             # COMMODORE INTERNATIONAL
00:80:11	DigitalInt             # DIGITAL SYSTEMS INT'L. INC.
00:80:12	Integrated             # INTEGRATED MEASUREMENT SYSTEMS
00:80:13	Thomas-Con             # THOMAS-CONRAD CORPORATION
00:80:14	Esprit                 # ESPRIT SYSTEMS
00:80:15	Seiko                  # SEIKO SYSTEMS, INC.
00:80:16	WandelAndG             # WANDEL AND GOLTERMANN
00:80:17	Pfu                    # PFU LIMITED
00:80:18	KobeSteel              # KOBE STEEL, LTD.
00:80:19	DaynaCommu             # DAYNA COMMUNICATIONS, INC.
00:80:1A	BellAtlant             # BELL ATLANTIC
00:80:1B	KodiakTech             # KODIAK TECHNOLOGY
00:80:1C	Cisco		# NEWPORT SYSTEMS SOLUTIONS
00:80:1D	Integrated             # INTEGRATED INFERENCE MACHINES
00:80:1E	Xinetron               # XINETRON, INC.
00:80:1F	KruppAtlas             # KRUPP ATLAS ELECTRONIK GMBH
00:80:20	NetworkPro             # NETWORK PRODUCTS
00:80:21	AlcatelCan             # Alcatel Canada Inc.
00:80:22	Scan-Optic             # SCAN-OPTICS
00:80:23	Integrated             # INTEGRATED BUSINESS NETWORKS
00:80:24	Kalpana                # KALPANA, INC.
00:80:25	Stollmann              # STOLLMANN GMBH
00:80:26	NetworkPro             # NETWORK PRODUCTS CORPORATION
00:80:27	Adaptive               # ADAPTIVE SYSTEMS, INC.
00:80:28	TradpostHk             # TRADPOST (HK) LTD
00:80:29	EagleTechn             # EAGLE TECHNOLOGY, INC.
00:80:2A	TestSimula             # TEST SYSTEMS & SIMULATIONS INC
00:80:2B	Integrated             # INTEGRATED MARKETING CO
00:80:2C	SageGroup              # THE SAGE GROUP PLC
00:80:2D	Xylogics               # XYLOGICS INC
00:80:2E	CastleRock             # CASTLE ROCK COMPUTING
00:80:2F	NationalIn             # NATIONAL INSTRUMENTS CORP.
00:80:30	NexusElect             # NEXUS ELECTRONICS
00:80:31	Basys                  # BASYS, CORP.
00:80:32	Access                 # ACCESS CO., LTD.
00:80:33	Formation              # FORMATION, INC.
00:80:34	SmtGoupil              # SMT GOUPIL
00:80:35	Technology             # TECHNOLOGY WORKS, INC.
00:80:36	ReflexManu             # REFLEX MANUFACTURING SYSTEMS
00:80:37	EricssonGr             # Ericsson Group
00:80:38	DataResear             # DATA RESEARCH & APPLICATIONS
00:80:39	AlcatelStc             # ALCATEL STC AUSTRALIA
00:80:3A	Varityper              # VARITYPER, INC.
00:80:3B	AptCommuni             # APT COMMUNICATIONS, INC.
00:80:3C	TvsElectro             # TVS ELECTRONICS LTD
00:80:3D	Surigiken              # SURIGIKEN CO.,  LTD.
00:80:3E	Synernetic             # SYNERNETICS
00:80:3F	Tatung                 # TATUNG COMPANY
00:80:40	JohnFlukeM             # JOHN FLUKE MANUFACTURING CO.
00:80:41	VebKombina             # VEB KOMBINAT ROBOTRON
00:80:42	ForceCompu             # FORCE COMPUTERS
00:80:43	Networld               # NETWORLD, INC.
00:80:44	SystechCom             # SYSTECH COMPUTER CORP.
00:80:45	Matsushita             # MATSUSHITA ELECTRIC IND. CO
00:80:46	University             # UNIVERSITY OF TORONTO
00:80:47	In-Net                 # IN-NET CORP.
00:80:48	Compex                 # COMPEX INCORPORATED
00:80:49	NissinElec             # NISSIN ELECTRIC CO., LTD.
00:80:4A	Pro-Log
00:80:4B	EagleTechn             # EAGLE TECHNOLOGIES PTY.LTD.
00:80:4C	Contec                 # CONTEC CO., LTD.
00:80:4D	CycloneMic             # CYCLONE MICROSYSTEMS, INC.
00:80:4E	ApexComput             # APEX COMPUTER COMPANY
00:80:4F	DaikinIndu             # DAIKIN INDUSTRIES, LTD.
00:80:50	Ziatech                # ZIATECH CORPORATION
00:80:51	Fibermux
00:80:52	Technicall             # TECHNICALLY ELITE CONCEPTS
00:80:53	Intellicom             # INTELLICOM, INC.
00:80:54	FrontierTe             # FRONTIER TECHNOLOGIES CORP.
00:80:55	Fermilab
00:80:56	SphinxElek             # SPHINX ELEKTRONIK GMBH
00:80:57	Adsoft                 # ADSOFT, LTD.
00:80:58	Printer                # PRINTER SYSTEMS CORPORATION
00:80:59	StanleyEle             # STANLEY ELECTRIC CO., LTD
00:80:5A	TulipCompu             # TULIP COMPUTERS INTERNAT'L B.V
00:80:5B	Condor                 # CONDOR SYSTEMS, INC.
00:80:5C	Agilis                 # AGILIS CORPORATION
00:80:5D	Canstar
00:80:5E	LsiLogic               # LSI LOGIC CORPORATION
00:80:5F	CompaqComp             # COMPAQ COMPUTER CORPORATION
00:80:60	NetworkInt             # NETWORK INTERFACE CORPORATION
00:80:61	Litton                 # LITTON SYSTEMS, INC.
00:80:62	Interface              # INTERFACE  CO.
00:80:63	RichardHir             # RICHARD HIRSCHMANN GMBH & CO.
00:80:64	WyseTechno             # WYSE TECHNOLOGY
00:80:65	Cybergraph             # CYBERGRAPHIC SYSTEMS PTY LTD.
00:80:66	ArcomContr             # ARCOM CONTROL SYSTEMS, LTD.
00:80:67	SquareD                # SQUARE D COMPANY
00:80:68	YamatechSc             # YAMATECH SCIENTIFIC LTD.
00:80:69	Computone              # COMPUTONE SYSTEMS
00:80:6A	EriEmpacRe             # ERI (EMPAC RESEARCH INC.)
00:80:6B	SchmidTele             # SCHMID TELECOMMUNICATION
00:80:6C	CegelecPro             # CEGELEC PROJECTS LTD
00:80:6D	Century                # CENTURY SYSTEMS CORP.
00:80:6E	NipponStee             # NIPPON STEEL CORPORATION
00:80:6F	Onelan                 # ONELAN LTD.
00:80:70	Computador             # COMPUTADORAS MICRON
00:80:71	SaiTechnol             # SAI TECHNOLOGY
00:80:72	Microplex              # MICROPLEX SYSTEMS LTD.
00:80:73	DwbAssocia             # DWB ASSOCIATES
00:80:74	FisherCont             # FISHER CONTROLS
00:80:75	Parsytec               # PARSYTEC GMBH
00:80:76	Mcnc
00:80:77	BrotherInd             # BROTHER INDUSTRIES, LTD.
00:80:78	PracticalP             # PRACTICAL PERIPHERALS, INC.
00:80:79	MicrobusDe             # MICROBUS DESIGNS LTD.
00:80:7A	Aitech                 # AITECH SYSTEMS LTD.
00:80:7B	ArtelCommu             # ARTEL COMMUNICATIONS CORP.
00:80:7C	Fibercom               # FIBERCOM, INC.
00:80:7D	Equinox                # EQUINOX SYSTEMS INC.
00:80:7E	SouthernPa             # SOUTHERN PACIFIC LTD.
00:80:7F	Dy-4                   # DY-4 INCORPORATED
00:80:80	Datamedia              # DATAMEDIA CORPORATION
00:80:81	KendallSqu             # KENDALL SQUARE RESEARCH CORP.
00:80:82	PepModular             # PEP MODULAR COMPUTERS GMBH
00:80:83	Amdahl
00:80:84	Cloud                  # THE CLOUD INC.
00:80:85	H-Three                # H-THREE SYSTEMS CORPORATION
00:80:86	ComputerGe             # COMPUTER GENERATION INC.
00:80:87	OkiElectri             # OKI ELECTRIC INDUSTRY CO., LTD
00:80:88	VictorOfJa             # VICTOR COMPANY OF JAPAN, LTD.
00:80:89	TecneticsP             # TECNETICS (PTY) LTD.
00:80:8A	SummitMicr             # SUMMIT MICROSYSTEMS CORP.
00:80:8B	Dacoll                 # DACOLL LIMITED
00:80:8C	Netscout               # NetScout Systems, Inc.
00:80:8D	WestcoastT             # WESTCOAST TECHNOLOGY B.V.
00:80:8E	RadstoneTe             # RADSTONE TECHNOLOGY
00:80:8F	CItohElect             # C. ITOH ELECTRONICS, INC.
00:80:90	MicrotekIn             # MICROTEK INTERNATIONAL, INC.
00:80:91	TokyoElect             # TOKYO ELECTRIC CO.,LTD
00:80:92	JapanCompu             # JAPAN COMPUTER INDUSTRY, INC.
00:80:93	Xyron                  # XYRON CORPORATION
00:80:94	AlfaLavalA             # ALFA LAVAL AUTOMATION AB
00:80:95	BasicMerto             # BASIC MERTON HANDELSGES.M.B.H.
00:80:96	HDS
00:80:97	CentralpAu             # CENTRALP AUTOMATISMES
00:80:98	Tdk                    # TDK CORPORATION
00:80:99	KlocknerMo             # KLOCKNER MOELLER IPC
00:80:9A	NovusNetwo             # NOVUS NETWORKS LTD
00:80:9B	Justsystem             # JUSTSYSTEM CORPORATION
00:80:9C	Luxcom                 # LUXCOM, INC.
00:80:9D	Commscraft             # Commscraft Ltd.
00:80:9E	Datus                  # DATUS GMBH
00:80:9F	AlcatelBus             # ALCATEL BUSINESS SYSTEMS
00:80:A0	EdisaHewle             # EDISA HEWLETT PACKARD S/A
00:80:A1	Microtest              # MICROTEST, INC.
00:80:A2	CreativeEl             # CREATIVE ELECTRONIC SYSTEMS
00:80:A3	Lantronix
00:80:A4	LibertyEle             # LIBERTY ELECTRONICS
00:80:A5	SpeedInter             # SPEED INTERNATIONAL
00:80:A6	RepublicTe             # REPUBLIC TECHNOLOGY, INC.
00:80:A7	Measurex               # MEASUREX CORP.
00:80:A8	Vitacom                # VITACOM CORPORATION
00:80:A9	Clearpoint             # CLEARPOINT RESEARCH
00:80:AA	Maxpeed
00:80:AB	DukaneNetw             # DUKANE NETWORK INTEGRATION
00:80:AC	ImlogixDiv             # IMLOGIX, DIVISION OF GENESYS
00:80:AD	Telebit
00:80:AE	HughesNetw             # HUGHES NETWORK SYSTEMS
00:80:AF	Allumer                # ALLUMER CO., LTD.
00:80:B0	AdvancedIn             # ADVANCED INFORMATION
00:80:B1	Softcom                # SOFTCOM A/S
00:80:B2	NetworkEqu             # NETWORK EQUIPMENT TECHNOLOGIES
00:80:B3	AvalData               # AVAL DATA CORPORATION
00:80:B4	Sophia                 # SOPHIA SYSTEMS
00:80:B5	UnitedNetw             # UNITED NETWORKS INC.
00:80:B6	ThemisComp             # THEMIS COMPUTER
00:80:B7	StellarCom             # STELLAR COMPUTER
00:80:B8	Bug                    # BUG, INCORPORATED
00:80:B9	ArcheTechn             # ARCHE TECHNOLIGIES INC.
00:80:BA	SpecialixA             # SPECIALIX (ASIA) PTE, LTD
00:80:BB	HughesLan              # HUGHES LAN SYSTEMS
00:80:BC	HitachiEng             # HITACHI ENGINEERING CO., LTD
00:80:BD	FurukawaEl             # THE FURUKAWA ELECTRIC CO., LTD
00:80:BE	AriesResea             # ARIES RESEARCH
00:80:BF	TakaokaEle             # TAKAOKA ELECTRIC MFG. CO. LTD.
00:80:C0	PenrilData             # PENRIL DATACOMM
00:80:C1	Lanex                  # LANEX CORPORATION
00:80:C2	Ieee8021Co             # IEEE 802.1 COMMITTEE
00:80:C3	BiccInform             # BICC INFORMATION SYSTEMS & SVC
00:80:C4	DocumentTe             # DOCUMENT TECHNOLOGIES, INC.
00:80:C5	NovellcoDe             # NOVELLCO DE MEXICO
00:80:C6	NationalDa             # NATIONAL DATACOMM CORPORATION
00:80:C7	Xircom
00:80:C8	D-Link                 # D-LINK SYSTEMS, INC.
00:80:C9	AlbertaMic             # ALBERTA MICROELECTRONIC CENTRE
00:80:CA	NetcomRese             # NETCOM RESEARCH INCORPORATED
00:80:CB	FalcoDataP             # FALCO DATA PRODUCTS
00:80:CC	MicrowaveB             # MICROWAVE BYPASS SYSTEMS
00:80:CD	MicronicsC             # MICRONICS COMPUTER, INC.
00:80:CE	BroadcastT             # BROADCAST TELEVISION SYSTEMS
00:80:CF	EmbeddedPe             # EMBEDDED PERFORMANCE INC.
00:80:D0	ComputerPe             # COMPUTER PERIPHERALS, INC.
00:80:D1	Kimtron                # KIMTRON CORPORATION
00:80:D2	Shinnihond             # SHINNIHONDENKO CO., LTD.
00:80:D3	Shiva                  # SHIVA CORP.
00:80:D4	ChaseResea             # CHASE RESEARCH LTD.
00:80:D5	CadreTechn             # CADRE TECHNOLOGIES
00:80:D6	Nuvotech               # NUVOTECH, INC.
00:80:D7	FantumEngi             # Fantum Engineering
00:80:D8	NetworkPer             # NETWORK PERIPHERALS INC.
00:80:D9	EmkElektro             # EMK ELEKTRONIK
00:80:DA	BruelKjaer             # BRUEL & KJAER
00:80:DB	Graphon                # GRAPHON CORPORATION
00:80:DC	PickerInte             # PICKER INTERNATIONAL
00:80:DD	GmxInc/Gim             # GMX INC/GIMIX
00:80:DE	GipsiSA                # GIPSI S.A.
00:80:DF	AdcCodenol             # ADC CODENOLL TECHNOLOGY CORP.
00:80:E0	Xtp                    # XTP SYSTEMS, INC.
00:80:E1	Stmicroele             # STMICROELECTRONICS
00:80:E2	TDI                    # T.D.I. CO., LTD.
00:80:E3	CoralNetwo             # CORAL NETWORK CORPORATION
00:80:E4	NorthwestD             # NORTHWEST DIGITAL SYSTEMS, INC
00:80:E5	LsiLogic               # LSI Logic Corporation
00:80:E6	PeerNetwor             # PEER NETWORKS, INC.
00:80:E7	LynwoodSci             # LYNWOOD SCIENTIFIC DEV. LTD.
00:80:E8	CumulusCor             # CUMULUS CORPORATIION
00:80:E9	Madge                  # Madge Ltd.
00:80:EA	AdvaOptica             # ADVA Optical Networking Ltd.
00:80:EB	Compcontro             # COMPCONTROL B.V.
00:80:EC	Supercompu             # SUPERCOMPUTING SOLUTIONS, INC.
00:80:ED	IqTechnolo             # IQ TECHNOLOGIES, INC.
00:80:EE	ThomsonCsf             # THOMSON CSF
00:80:EF	Rational
00:80:F0	PanasonicC             # Panasonic Communications Co., Ltd.
00:80:F1	Opus                   # OPUS SYSTEMS
00:80:F2	Raycom                 # RAYCOM SYSTEMS INC
00:80:F3	SunElectro             # SUN ELECTRONICS CORP.
00:80:F4	Telemecani             # TELEMECANIQUE ELECTRIQUE
00:80:F5	Quantel                # QUANTEL LTD
00:80:F6	SynergyMic             # SYNERGY MICROSYSTEMS
00:80:F7	ZenithElec             # ZENITH ELECTRONICS
00:80:F8	Mizar                  # MIZAR, INC.
00:80:F9	Heurikon               # HEURIKON CORPORATION
00:80:FA	Rwt                    # RWT GMBH
00:80:FB	Bvm                    # BVM LIMITED
00:80:FC	Avatar                 # AVATAR CORPORATION
00:80:FD	ExsceedCor             # EXSCEED CORPRATION
00:80:FE	AzureTechn             # AZURE TECHNOLOGIES, INC.
00:80:FF	SocDeTelei             # SOC. DE TELEINFORMATIQUE RTC
00:90:00	DiamondMul             # DIAMOND MULTIMEDIA
00:90:01	NishimuEle             # NISHIMU ELECTRONICS INDUSTRIES CO., LTD.
00:90:02	Allgon                 # ALLGON AB
00:90:03	Aplio
00:90:04	3comEurope             # 3COM EUROPE LTD.
00:90:05	Protech                # PROTECH SYSTEMS CO., LTD.
00:90:06	HamamatsuP             # HAMAMATSU PHOTONICS K.K.
00:90:07	DomexTechn             # DOMEX TECHNOLOGY CORP.
00:90:08	Hana                   # HanA Systems Inc.
00:90:09	IControls              # i Controls, Inc.
00:90:0A	ProtonElec             # PROTON ELECTRONIC INDUSTRIAL CO., LTD.
00:90:0B	LannerElec             # LANNER ELECTRONICS, INC.
00:90:0C	Cisco                  # CISCO SYSTEMS, INC.
00:90:0D	OverlandDa             # OVERLAND DATA INC.
00:90:0E	HandlinkTe             # HANDLINK TECHNOLOGIES, INC.
00:90:0F	KawasakiHe             # KAWASAKI HEAVY INDUSTRIES, LTD
00:90:10	Simulation             # SIMULATION LABORATORIES, INC.
00:90:11	Wavtrace               # WAVTrace, Inc.
00:90:12	GlobespanS             # GLOBESPAN SEMICONDUCTOR, INC.
00:90:13	Samsan                 # SAMSAN CORP.
00:90:14	RotorkInst             # ROTORK INSTRUMENTS, LTD.
00:90:15	CentigramC             # CENTIGRAM COMMUNICATIONS CORP.
00:90:16	Zac
00:90:17	Zypcom                 # ZYPCOM, INC.
00:90:18	ItoElectri             # ITO ELECTRIC INDUSTRY CO, LTD.
00:90:19	HermesElec             # HERMES ELECTRONICS CO., LTD.
00:90:1A	UnisphereS             # UNISPHERE SOLUTIONS
00:90:1B	DigitalCon             # DIGITAL CONTROLS
00:90:1C	MpsSoftwar             # mps Software Gmbh
00:90:1D	PecNz                  # PEC (NZ) LTD.
00:90:1E	SelestaIng             # SELESTA INGEGNE RIA S.P.A.
00:90:1F	AdtecProdu             # ADTEC PRODUCTIONS, INC.
00:90:20	PhilipsAna             # PHILIPS ANALYTICAL X-RAY B.V.
00:90:21	Cisco                  # CISCO SYSTEMS, INC.
00:90:22	Ivex
00:90:23	Zilog                  # ZILOG INC.
00:90:24	Pipelinks              # PIPELINKS, INC.
00:90:25	VisionPty              # VISION SYSTEMS LTD. PTY
00:90:26	AdvancedSw             # ADVANCED SWITCHING COMMUNICATIONS, INC.
00:90:27	Intel                  # INTEL CORPORATION
00:90:28	NipponSign             # NIPPON SIGNAL CO., LTD.
00:90:29	Crypto                 # CRYPTO AG
00:90:2A	Communicat             # COMMUNICATION DEVICES, INC.
00:90:2B	Cisco                  # CISCO SYSTEMS, INC.
00:90:2C	DataContro             # DATA & CONTROL EQUIPMENT LTD.
00:90:2D	DataElectr             # DATA ELECTRONICS (AUST.) PTY, LTD.
00:90:2E	Namco                  # NAMCO LIMITED
00:90:2F	Netcore                # NETCORE SYSTEMS, INC.
00:90:30	Honeywell-             # HONEYWELL-DATING
00:90:31	Mysticom               # MYSTICOM, LTD.
00:90:32	PelcombeGr             # PELCOMBE GROUP LTD.
00:90:33	Innovaphon             # INNOVAPHONE AG
00:90:34	Imagic                 # IMAGIC, INC.
00:90:35	AlphaTelec             # ALPHA TELECOM, INC.
00:90:36	Ens                    # ens, inc.
00:90:37	Acucomm                # ACUCOMM, INC.
00:90:38	FountainTe             # FOUNTAIN TECHNOLOGIES, INC.
00:90:39	ShastaNetw             # SHASTA NETWORKS
00:90:3A	NihonMedia             # NIHON MEDIA TOOL INC.
00:90:3B	TriemsRese             # TriEMS Research Lab, Inc.
00:90:3C	AtlanticNe             # ATLANTIC NETWORK SYSTEMS
00:90:3D	Biopac                 # BIOPAC SYSTEMS, INC.
00:90:3E	NVPhilipsI             # N.V. PHILIPS INDUSTRIAL ACTIVITIES
00:90:3F	AztecRadio             # AZTEC RADIOMEDIA
00:90:40	SiemensNet             # Siemens Network Convergence LLC
00:90:41	AppliedDig             # APPLIED DIGITAL ACCESS
00:90:42	Eccs                   # ECCS, Inc.
00:90:43	NichibeiDe             # NICHIBEI DENSHI CO., LTD.
00:90:44	AssuredDig             # ASSURED DIGITAL, INC.
00:90:45	MarconiCom             # Marconi Communications
00:90:46	Dexdyne                # DEXDYNE, LTD.
00:90:47	GigaFastE              # GIGA FAST E. LTD.
00:90:48	Zeal                   # ZEAL CORPORATION
00:90:49	Entridia               # ENTRIDIA CORPORATION
00:90:4A	ConcurSyst             # CONCUR SYSTEM TECHNOLOGIES
00:90:4B	GemtekTech             # GemTek Technology Co., Ltd.
00:90:4C	Epigram                # EPIGRAM, INC.
00:90:4D	SpecSA                 # SPEC S.A.
00:90:4E	DelemBv                # DELEM BV
00:90:4F	AbbPowerT&             # ABB POWER T&D COMPANY, INC.
00:90:50	TelesteOy              # TELESTE OY
00:90:51	UltimateTe             # ULTIMATE TECHNOLOGY CORP.
00:90:52	SelcomElet             # SELCOM ELETTRONICA S.R.L.
00:90:53	DaewooElec             # DAEWOO ELECTRONICS CO., LTD.
00:90:54	Innovative             # INNOVATIVE SEMICONDUCTORS, INC
00:90:55	ParkerHann             # PARKER HANNIFIN CORPORATION COMPUMOTOR DIVISION
00:90:56	Telestream             # TELESTREAM, INC.
00:90:57	Aanetcom               # AANetcom, Inc.
00:90:58	UltraElect             # Ultra Electronics Ltd., Command and Control Systems
00:90:59	TelecomDev             # TELECOM DEVICE K.K.
00:90:5A	DearbornGr             # DEARBORN GROUP, INC.
00:90:5B	RaymondAnd             # RAYMOND AND LAE ENGINEERING
00:90:5C	Edmi
00:90:5D	NetcomSich             # NETCOM SICHERHEITSTECHNIK GmbH
00:90:5E	Rauland-Bo             # RAULAND-BORG CORPORATION
00:90:5F	Cisco                  # CISCO SYSTEMS, INC.
00:90:60	SystemCrea             # SYSTEM CREATE CORP.
00:90:61	PacificRes             # PACIFIC RESEARCH & ENGINEERING CORPORATION
00:90:62	IcpVortexC             # ICP VORTEX COMPUTERSYSTEME GmbH
00:90:63	CoherentCo             # COHERENT COMMUNICATIONS SYSTEMS CORPORATION
00:90:64	ThomsonBro             # THOMSON BROADCAST SYSTEMS
00:90:65	Finisar                # FINISAR CORPORATION
00:90:66	TroikaNetw             # Troika Networks, Inc.
00:90:67	WalkaboutC             # WalkAbout Computers, Inc.
00:90:68	Dvt                    # DVT CORP.
00:90:69	JuniperNet             # JUNIPER NETWORKS, INC.
00:90:6A	Turnstone              # TURNSTONE SYSTEMS, INC.
00:90:6B	AppliedRes             # APPLIED RESOURCES, INC.
00:90:6C	SartoriusH             # Sartorius Hamburg GmbH
00:90:6D	Cisco                  # CISCO SYSTEMS, INC.
00:90:6E	Praxon                 # PRAXON, INC.
00:90:6F	Cisco                  # CISCO SYSTEMS, INC.
00:90:70	NeoNetwork             # NEO NETWORKS, INC.
00:90:71	AppliedInn             # Applied Innovation Inc.
00:90:72	SimradAs               # SIMRAD AS
00:90:73	GaioTechno             # GAIO TECHNOLOGY
00:90:74	ArgonNetwo             # ARGON NETWORKS, INC.
00:90:75	NecDoBrasi             # NEC DO BRASIL S.A.
00:90:76	FmtAircraf             # FMT AIRCRAFT GATE SUPPORT SYSTEMS AB
00:90:77	AdvancedFi             # ADVANCED FIBRE COMMUNICATIONS
00:90:78	MerTeleman             # MER TELEMANAGEMENT SOLUTIONS, LTD.
00:90:79	Clearone               # ClearOne, Inc.
00:90:7A	Spectralin             # SPECTRALINK CORP.
00:90:7B	E-Tech                 # E-TECH, INC.
00:90:7C	Digitalcas             # DIGITALCAST, INC.
00:90:7D	LakeCommun             # Lake Communications
00:90:7E	Vetronix               # VETRONIX CORP.
00:90:7F	Watchguard             # WatchGuard Technologies, Inc.
00:90:80	Not                    # NOT LIMITED, INC.
00:90:81	AlohaNetwo             # ALOHA NETWORKS, INC.
00:90:82	ForceInsti             # FORCE INSTITUTE
00:90:83	TurboCommu             # TURBO COMMUNICATION, INC.
00:90:84	AtechSyste             # ATECH SYSTEM
00:90:85	GoldenEnte             # GOLDEN ENTERPRISES, INC.
00:90:86	Cisco                  # CISCO SYSTEMS, INC.
00:90:87	Itis
00:90:88	BaxallSecu             # BAXALL SECURITY LTD.
00:90:89	SoftcomMic             # SOFTCOM MICROSYSTEMS, INC.
00:90:8A	BaylyCommu             # BAYLY COMMUNICATIONS, INC.
00:90:8B	Pfu                    # PFU Systems, Inc.
00:90:8C	EtrendElec             # ETREND ELECTRONICS, INC.
00:90:8D	VickersEle             # VICKERS ELECTRONICS SYSTEMS
00:90:8E	NortelNetw             # Nortel Networks Broadband Access
00:90:8F	AudioCodes             # AUDIO CODES LTD.
00:90:90	I-Bus
00:90:91	Digitalsca             # DigitalScape, Inc.
00:90:92	Cisco                  # CISCO SYSTEMS, INC.
00:90:93	Nanao                  # NANAO CORPORATION
00:90:94	OspreyTech             # OSPREY TECHNOLOGIES, INC.
00:90:95	UniversalA             # UNIVERSAL AVIONICS
00:90:96	AskeyCompu             # ASKEY COMPUTER CORP.
00:90:97	SycamoreNe             # SYCAMORE NETWORKS
00:90:98	SbcDesigns             # SBC DESIGNS, INC.
00:90:99	AlliedTele             # ALLIED TELESIS, K.K.
00:90:9A	OneWorld               # ONE WORLD SYSTEMS, INC.
00:90:9B	Markpoint              # MARKPOINT AB
00:90:9C	TerayonCom             # Terayon Communications Systems
00:90:9D	NovatechPr             # NovaTech Process Solutions, LLC
00:90:9E	CriticalIo             # Critical IO, LLC
00:90:9F	Digi-Data              # DIGI-DATA CORPORATION
00:90:A0	8x8                    # 8X8 INC.
00:90:A1	FlyingPig              # FLYING PIG SYSTEMS, LTD.
00:90:A2	CybertanTe             # CYBERTAN TECHNOLOGY, INC.
00:90:A3	Corecess               # Corecess Inc.
00:90:A4	AltigaNetw             # ALTIGA NETWORKS
00:90:A5	SpectraLog             # SPECTRA LOGIC
00:90:A6	Cisco                  # CISCO SYSTEMS, INC.
00:90:A7	Clientec               # CLIENTEC CORPORATION
00:90:A8	NinetilesN             # NineTiles Networks, Ltd.
00:90:A9	WesternDig             # WESTERN DIGITAL
00:90:AA	IndigoActi             # INDIGO ACTIVE VISION SYSTEMS LIMITED
00:90:AB	Cisco                  # CISCO SYSTEMS, INC.
00:90:AC	Optivision             # OPTIVISION, INC.
00:90:AD	AspectElec             # ASPECT ELECTRONICS, INC.
00:90:AE	ItaltelSPA             # ITALTEL S.p.A.
00:90:AF	JMoritaMfg             # J. MORITA MFG. CORP.
00:90:B0	Vadem
00:90:B1	Cisco                  # CISCO SYSTEMS, INC.
00:90:B2	Avici                  # AVICI SYSTEMS INC.
00:90:B3	Agranat                # AGRANAT SYSTEMS
00:90:B4	Willowbroo             # WILLOWBROOK TECHNOLOGIES
00:90:B5	Nikon                  # NIKON CORPORATION
00:90:B6	Fibex                  # FIBEX SYSTEMS
00:90:B7	DigitalLig             # DIGITAL LIGHTWAVE, INC.
00:90:B8	RohdeSchwa             # ROHDE & SCHWARZ GMBH & CO. KG
00:90:B9	BeranInstr             # BERAN INSTRUMENTS LTD.
00:90:BA	ValidNetwo             # VALID NETWORKS, INC.
00:90:BB	TainetComm             # TAINET COMMUNICATION SYSTEM Corp.
00:90:BC	Telemann               # TELEMANN CO., LTD.
00:90:BD	OmniaCommu             # OMNIA COMMUNICATIONS, INC.
00:90:BE	Ibc/Integr             # IBC/INTEGRATED BUSINESS COMPUTERS
00:90:BF	Cisco                  # CISCO SYSTEMS, INC.
00:90:C0	KJLawEngin             # K.J. LAW ENGINEERS, INC.
00:90:C1	PecoIi                 # Peco II, Inc.
00:90:C2	JkMicrosys             # JK microsystems, Inc.
00:90:C3	TopicSemic             # TOPIC SEMICONDUCTOR CORP.
00:90:C4	Javelin                # JAVELIN SYSTEMS, INC.
00:90:C5	InternetMa             # INTERNET MAGIC, INC.
00:90:C6	Optim                  # OPTIM SYSTEMS, INC.
00:90:C7	Icom                   # ICOM INC.
00:90:C8	WaveriderC             # WAVERIDER COMMUNICATIONS (CANADA) INC.
00:90:C9	DpacTechno             # DPAC Technologies
00:90:CA	AccordVide             # ACCORD VIDEO TELECOMMUNICATIONS, LTD.
00:90:CB	WirelessOn             # Wireless OnLine, Inc.
00:90:CC	PlanetComm             # PLANET COMMUNICATIONS, INC.
00:90:CD	Ent-Empres             # ENT-EMPRESA NACIONAL DE TELECOMMUNICACOES, S.A.
00:90:CE	Tetra                  # TETRA GmbH
00:90:CF	Nortel
00:90:D0	ThomsonTel             # Thomson Telecom Belgium
00:90:D1	LeichuEnte             # LEICHU ENTERPRISE CO., LTD.
00:90:D2	ArtelVideo             # ARTEL VIDEO SYSTEMS
00:90:D3	GieseckeDe             # GIESECKE & DEVRIENT GmbH
00:90:D4	BindviewDe             # BindView Development Corp.
00:90:D5	Euphonix               # EUPHONIX, INC.
00:90:D6	CrystalGro             # CRYSTAL GROUP
00:90:D7	Netboost               # NetBoost Corp.
00:90:D8	Whitecross             # WHITECROSS SYSTEMS
00:90:D9	Cisco                  # CISCO SYSTEMS, INC.
00:90:DA	Dynarc                 # DYNARC, INC.
00:90:DB	NextLevelC             # NEXT LEVEL COMMUNICATIONS
00:90:DC	TecoInform             # TECO INFORMATION SYSTEMS
00:90:DD	MiharuComm             # THE MIHARU COMMUNICATIONS CO., LTD.
00:90:DE	Cardkey                # CARDKEY SYSTEMS, INC.
00:90:DF	Mitsubishi             # MITSUBISHI CHEMICAL AMERICA, INC.
00:90:E0	Systran                # SYSTRAN CORP.
00:90:E1	TelenaSPA              # TELENA S.P.A.
00:90:E2	Distribute             # DISTRIBUTED PROCESSING TECHNOLOGY
00:90:E3	AvexElectr             # AVEX ELECTRONICS INC.
00:90:E4	NecAmerica             # NEC AMERICA, INC.
00:90:E5	Teknema                # TEKNEMA, INC.
00:90:E6	AcerLabora             # ACER LABORATORIES, INC.
00:90:E7	HorschElek             # HORSCH ELEKTRONIK AG
00:90:E8	MoxaTechno             # MOXA TECHNOLOGIES CORP., LTD.
00:90:E9	JanzComput             # JANZ COMPUTER AG
00:90:EA	AlphaTechn             # ALPHA TECHNOLOGIES, INC.
00:90:EB	SentryTele             # SENTRY TELECOM SYSTEMS
00:90:EC	Pyrescom
00:90:ED	CentralSys             # CENTRAL SYSTEM RESEARCH CO., LTD.
00:90:EE	PersonalCo             # PERSONAL COMMUNICATIONS TECHNOLOGIES
00:90:EF	Integrix               # INTEGRIX, INC.
00:90:F0	HarmonicVi             # Harmonic Video Systems Ltd.
00:90:F1	DotHill                # DOT HILL SYSTEMS CORPORATION
00:90:F2	Cisco                  # CISCO SYSTEMS, INC.
00:90:F3	AspectComm             # ASPECT COMMUNICATIONS
00:90:F4	LightningI             # LIGHTNING INSTRUMENTATION
00:90:F5	Clevo                  # CLEVO CO.
00:90:F6	EscalateNe             # ESCALATE NETWORKS, INC.
00:90:F7	NbaseCommu             # NBASE COMMUNICATIONS LTD.
00:90:F8	MediatrixT             # MEDIATRIX TELECOM
00:90:F9	Leitch
00:90:FA	Emulex                 # EMULEX Corp
00:90:FB	Portwell               # PORTWELL, INC.
00:90:FC	NetworkCom             # NETWORK COMPUTING DEVICES
00:90:FD	Coppercom              # CopperCom, Inc.
00:90:FE	ElecomLane             # ELECOM CO., LTD.  (LANEED DIV.)
00:90:FF	TellusTech             # TELLUS TECHNOLOGY INC.
00:91:D6	CrystalGro             # Crystal Group, Inc.
00:9D:8E	CardiacRec             # CARDIAC RECORDERS, INC.
00:A0:00	Centillion             # CENTILLION NETWORKS, INC.
00:A0:01	DrsSignalS             # DRS Signal Solutions
00:A0:02	LeedsNorth             # LEEDS & NORTHRUP AUSTRALIA PTY LTD
00:A0:03	StaefaCont             # STAEFA CONTROL SYSTEM
00:A0:04	Netpower               # NETPOWER, INC.
00:A0:05	DanielInst             # DANIEL INSTRUMENTS, LTD.
00:A0:06	ImageDataP             # IMAGE DATA PROCESSING SYSTEM GROUP
00:A0:07	ApexxTechn             # APEXX TECHNOLOGY, INC.
00:A0:08	Netcorp
00:A0:09	WhitetreeN             # WHITETREE NETWORK
00:A0:0A	RDCCommuni             # R.D.C. COMMUNICATION
00:A0:0B	Computex               # COMPUTEX CO., LTD.
00:A0:0C	KingmaxTec             # KINGMAX TECHNOLOGY, INC.
00:A0:0D	PandaProje             # THE PANDA PROJECT
00:A0:0E	VisualNetw             # VISUAL NETWORKS, INC.
00:A0:0F	BroadbandT             # Broadband Technologies
00:A0:10	SyslogicDa             # SYSLOGIC DATENTECHNIK AG
00:A0:11	MutohIndus             # MUTOH INDUSTRIES LTD.
00:A0:12	BATMAdvanc             # B.A.T.M. ADVANCED TECHNOLOGIES
00:A0:13	Teltrend               # TELTREND LTD.
00:A0:14	Csir
00:A0:15	Wyle
00:A0:16	Micropolis             # MICROPOLIS CORP.
00:A0:17	JBM                    # J B M CORPORATION
00:A0:18	CreativeCo             # CREATIVE CONTROLLERS, INC.
00:A0:19	NebulaCons             # NEBULA CONSULTANTS, INC.
00:A0:1A	BinarElekt             # BINAR ELEKTRONIK AB
00:A0:1B	PremisysCo             # PREMISYS COMMUNICATIONS, INC.
00:A0:1C	NascentNet             # NASCENT NETWORKS CORPORATION
00:A0:1D	Sixnet
00:A0:1E	Est                    # EST CORPORATION
00:A0:1F	Tricord                # TRICORD SYSTEMS, INC.
00:A0:20	Citicorp/T             # CITICORP/TTI
00:A0:21	GeneralDyn             # General Dynamics
00:A0:22	CentreForD             # CENTRE FOR DEVELOPMENT OF ADVANCED COMPUTING
00:A0:23	AppliedCre             # APPLIED CREATIVE TECHNOLOGY, INC.
00:A0:24	3com                   # 3COM CORPORATION
00:A0:25	RedcomLabs             # REDCOM LABS INC.
00:A0:26	TeldatSA               # TELDAT, S.A.
00:A0:27	Firepower              # FIREPOWER SYSTEMS, INC.
00:A0:28	ConnerPeri             # CONNER PERIPHERALS
00:A0:29	Coulter                # COULTER CORPORATION
00:A0:2A	Trancell               # TRANCELL SYSTEMS
00:A0:2B	Transition             # TRANSITIONS RESEARCH CORP.
00:A0:2C	InterwaveC             # interWAVE Communications
00:A0:2D	1394TradeA             # 1394 Trade Association
00:A0:2E	BrandCommu             # BRAND COMMUNICATIONS, LTD.
00:A0:2F	PirelliCav             # PIRELLI CAVI
00:A0:30	CaptorNv/S             # CAPTOR NV/SA
00:A0:31	HazeltineM             # HAZELTINE CORPORATION, MS 1-17
00:A0:32	GesSingapo             # GES SINGAPORE PTE. LTD.
00:A0:33	ImcMebsyst             # imc MeBsysteme GmbH
00:A0:34	Axel
00:A0:35	Cylink                 # CYLINK CORPORATION
00:A0:36	AppliedNet             # APPLIED NETWORK TECHNOLOGY
00:A0:37	Datascope              # DATASCOPE CORPORATION
00:A0:38	EmailElect             # EMAIL ELECTRONICS
00:A0:39	RossTechno             # ROSS TECHNOLOGY, INC.
00:A0:3A	Kubotek                # KUBOTEK CORPORATION
00:A0:3B	ToshinElec             # TOSHIN ELECTRIC CO., LTD.
00:A0:3C	Eg&GNuclea             # EG&G NUCLEAR INSTRUMENTS
00:A0:3D	Opto-22
00:A0:3E	AtmForum               # ATM FORUM
00:A0:3F	ComputerSo             # COMPUTER SOCIETY MICROPROCESSOR & MICROPROCESSOR STANDARDS C
00:A0:40	AppleCompu             # APPLE COMPUTER
00:A0:41	Inficon
00:A0:42	SpurProduc             # SPUR PRODUCTS CORP.
00:A0:43	AmericanTe             # AMERICAN TECHNOLOGY LABS, INC.
00:A0:44	NttIt                  # NTT IT CO., LTD.
00:A0:45	PhoenixCon             # PHOENIX CONTACT GMBH & CO.
00:A0:46	Scitex                 # SCITEX CORP. LTD.
00:A0:47	Integrated             # INTEGRATED FITNESS CORP.
00:A0:48	Questech               # QUESTECH, LTD.
00:A0:49	DigitechIn             # DIGITECH INDUSTRIES, INC.
00:A0:4A	NisshinEle             # NISSHIN ELECTRIC CO., LTD.
00:A0:4B	TflLan                 # TFL LAN INC.
00:A0:4C	Innovative             # INNOVATIVE SYSTEMS & TECHNOLOGIES, INC.
00:A0:4D	EdaInstrum             # EDA INSTRUMENTS, INC.
00:A0:4E	VoelkerTec             # VOELKER TECHNOLOGIES, INC.
00:A0:4F	Ameritec               # AMERITEC CORP.
00:A0:50	CypressSem             # CYPRESS SEMICONDUCTOR
00:A0:51	AngiaCommu             # ANGIA COMMUNICATIONS. INC.
00:A0:52	StaniliteE             # STANILITE ELECTRONICS PTY. LTD
00:A0:53	CompactDev             # COMPACT DEVICES, INC.
00:A0:54	Private
00:A0:55	DataDevice             # Data Device Corporation
00:A0:56	Micropross
00:A0:57	Lancom                 # LANCOM Systems GmbH
00:A0:58	Glory                  # GLORY, LTD.
00:A0:59	HamiltonHa             # HAMILTON HALLMARK
00:A0:5A	KofaxImage             # KOFAX IMAGE PRODUCTS
00:A0:5B	Marquip                # MARQUIP, INC.
00:A0:5C	InventoryC             # INVENTORY CONVERSION, INC./
00:A0:5D	CsComputer             # CS COMPUTER SYSTEME GmbH
00:A0:5E	MyriadLogi             # MYRIAD LOGIC INC.
00:A0:5F	BtgEnginee             # BTG ENGINEERING BV
00:A0:60	AcerPeriph             # ACER PERIPHERALS, INC.
00:A0:61	PuritanBen             # PURITAN BENNETT
00:A0:62	AesProdata             # AES PRODATA
00:A0:63	Jrl                    # JRL SYSTEMS, INC.
00:A0:64	Kvb/Analec             # KVB/ANALECT
00:A0:65	Symantec               # Symantec Corporation
00:A0:66	Isa                    # ISA CO., LTD.
00:A0:67	NetworkSer             # NETWORK SERVICES GROUP
00:A0:68	Bhp                    # BHP LIMITED
00:A0:69	Symmetrico             # Symmetricom, Inc.
00:A0:6A	Verilink               # Verilink Corporation
00:A0:6B	DmsDorschM             # DMS DORSCH MIKROSYSTEM GMBH
00:A0:6C	Shindengen             # SHINDENGEN ELECTRIC MFG. CO., LTD.
00:A0:6D	Mannesmann             # MANNESMANN TALLY CORPORATION
00:A0:6E	Austron                # AUSTRON, INC.
00:A0:6F	AppconGrou             # THE APPCON GROUP, INC.
00:A0:70	Coastcom
00:A0:71	VideoLotte             # VIDEO LOTTERY TECHNOLOGIES,INC
00:A0:72	Ovation                # OVATION SYSTEMS LTD.
00:A0:73	Com21                  # COM21, INC.
00:A0:74	Perception             # PERCEPTION TECHNOLOGY
00:A0:75	MicronTech             # MICRON TECHNOLOGY, INC.
00:A0:76	CardwareLa             # CARDWARE LAB, INC.
00:A0:77	FujitsuNex             # FUJITSU NEXION, INC.
00:A0:78	MarconiCom             # Marconi Communications
00:A0:79	AlpsElectr             # ALPS ELECTRIC (USA), INC.
00:A0:7A	AdvancedPe             # ADVANCED PERIPHERALS TECHNOLOGIES, INC.
00:A0:7B	DawnComput             # DAWN COMPUTER INCORPORATION
00:A0:7C	TonyangNyl             # TONYANG NYLON CO., LTD.
00:A0:7D	SeeqTechno             # SEEQ TECHNOLOGY, INC.
00:A0:7E	AvidTechno             # AVID TECHNOLOGY, INC.
00:A0:7F	Gsm-Syntel             # GSM-SYNTEL, LTD.
00:A0:80	Sbe                    # SBE, Inc.
00:A0:81	AlcatelDat             # ALCATEL DATA NETWORKS
00:A0:82	NktElektro             # NKT ELEKTRONIK A/S
00:A0:83	Asimmphony             # ASIMMPHONY TURKEY
00:A0:84	DataplexPt             # DATAPLEX PTY. LTD.
00:A0:85	Private
00:A0:86	AmberWave              # AMBER WAVE SYSTEMS, INC.
00:A0:87	ZarlinkSem             # Zarlink Semiconductor Ltd.
00:A0:88	EssentialC             # ESSENTIAL COMMUNICATIONS
00:A0:89	XpointTech             # XPOINT TECHNOLOGIES, INC.
00:A0:8A	Brooktrout             # BROOKTROUT TECHNOLOGY, INC.
00:A0:8B	AstonElect             # ASTON ELECTRONIC DESIGNS LTD.
00:A0:8C	Multimedia             # MultiMedia LANs, Inc.
00:A0:8D	Jacomo                 # JACOMO CORPORATION
00:A0:8E	NokiaInter             # Nokia Internet Communications
00:A0:8F	Desknet                # DESKNET SYSTEMS, INC.
00:A0:90	Timestep               # TimeStep Corporation
00:A0:91	ApplicomIn             # APPLICOM INTERNATIONAL
00:A0:92	HBollmannM             # H. BOLLMANN MANUFACTURERS, LTD
00:A0:93	B/EAerospa             # B/E AEROSPACE, Inc.
00:A0:94	Comsat                 # COMSAT CORPORATION
00:A0:95	AcaciaNetw             # ACACIA NETWORKS, INC.
00:A0:96	MitumiElec             # MITUMI ELECTRIC CO., LTD.
00:A0:97	JcInformat             # JC INFORMATION SYSTEMS
00:A0:98	NetworkApp             # NETWORK APPLIANCE CORP.
00:A0:99	K-Net                  # K-NET LTD.
00:A0:9A	NihonKohde             # NIHON KOHDEN AMERICA
00:A0:9B	QpsxCommun             # QPSX COMMUNICATIONS, LTD.
00:A0:9C	Xyplex                 # Xyplex, Inc.
00:A0:9D	JohnathonF             # JOHNATHON FREEMAN TECHNOLOGIES
00:A0:9E	Ictv
00:A0:9F	Commvision             # COMMVISION CORP.
00:A0:A0	CompactDat             # COMPACT DATA, LTD.
00:A0:A1	EpicData               # EPIC DATA INC.
00:A0:A2	DigicomSPA             # DIGICOM S.P.A.
00:A0:A3	ReliablePo             # RELIABLE POWER METERS
00:A0:A4	Micros                 # MICROS SYSTEMS, INC.
00:A0:A5	TeknorMicr             # TEKNOR MICROSYSTEME, INC.
00:A0:A6	MIKK                   # M.I. SYSTEMS, K.K.
00:A0:A7	Vorax                  # VORAX CORPORATION
00:A0:A8	Renex                  # RENEX CORPORATION
00:A0:A9	NavtelComm             # NAVTEL COMMUNICATIONS INC.
00:A0:AA	SpacelabsM             # SPACELABS MEDICAL
00:A0:AB	NetcsInfor             # NETCS INFORMATIONSTECHNIK GMBH
00:A0:AC	GilatSatel             # GILAT SATELLITE NETWORKS, LTD.
00:A0:AD	MarconiSpa             # MARCONI SPA
00:A0:AE	Nucom                  # NUCOM SYSTEMS, INC.
00:A0:AF	WmsIndustr             # WMS INDUSTRIES
00:A0:B0	I-ODataDev             # I-O DATA DEVICE, INC.
00:A0:B1	FirstVirtu             # FIRST VIRTUAL CORPORATION
00:A0:B2	ShimaSeiki             # SHIMA SEIKI
00:A0:B3	Zykronix
00:A0:B4	TexasMicro             # TEXAS MICROSYSTEMS, INC.
00:A0:B5	3hTechnolo             # 3H TECHNOLOGY
00:A0:B6	SanritzAut             # SANRITZ AUTOMATION CO., LTD.
00:A0:B7	Cordant                # CORDANT, INC.
00:A0:B8	SymbiosLog             # SYMBIOS LOGIC INC.
00:A0:B9	EagleTechn             # EAGLE TECHNOLOGY, INC.
00:A0:BA	PattonElec             # PATTON ELECTRONICS CO.
00:A0:BB	Hilan                  # HILAN GMBH
00:A0:BC	Viasat                 # VIASAT, INCORPORATED
00:A0:BD	I-Tech                 # I-TECH CORP.
00:A0:BE	Integrated             # INTEGRATED CIRCUIT SYSTEMS, INC. COMMUNICATIONS GROUP
00:A0:BF	WirelessDa             # WIRELESS DATA GROUP MOTOROLA
00:A0:C0	DigitalLin             # DIGITAL LINK CORP.
00:A0:C1	OrtivusMed             # ORTIVUS MEDICAL AB
00:A0:C2	RA                     # R.A. SYSTEMS CO., LTD.
00:A0:C3	Unicompute             # UNICOMPUTER GMBH
00:A0:C4	CristieEle             # CRISTIE ELECTRONICS LTD.
00:A0:C5	ZyxelCommu             # ZYXEL COMMUNICATION
00:A0:C6	Qualcomm               # QUALCOMM INCORPORATED
00:A0:C7	TadiranTel             # TADIRAN TELECOMMUNICATIONS
00:A0:C8	Adtran                 # ADTRAN INC.
00:A0:C9	Intel-Hf1-             # INTEL CORPORATION - HF1-06
00:A0:CA	FujitsuDen             # FUJITSU DENSO LTD.
00:A0:CB	ArkTelecom             # ARK TELECOMMUNICATIONS, INC.
00:A0:CC	Lite-OnCom             # LITE-ON COMMUNICATIONS, INC.
00:A0:CD	DrJohannes             # DR. JOHANNES HEIDENHAIN GmbH
00:A0:CE	Astrocom               # ASTROCOM CORPORATION
00:A0:CF	Sotas                  # SOTAS, INC.
00:A0:D0	TenXTechno             # TEN X TECHNOLOGY, INC.
00:A0:D1	Inventec               # INVENTEC CORPORATION
00:A0:D2	AlliedTele             # ALLIED TELESIS INTERNATIONAL CORPORATION
00:A0:D3	InstemComp             # INSTEM COMPUTER SYSTEMS, LTD.
00:A0:D4	Radiolan               # RADIOLAN,  INC.
00:A0:D5	SierraWire             # SIERRA WIRELESS INC.
00:A0:D6	Sbe                    # SBE, INC.
00:A0:D7	KastenChas             # KASTEN CHASE APPLIED RESEARCH
00:A0:D8	Spectra-Te             # SPECTRA - TEK
00:A0:D9	ConvexComp             # CONVEX COMPUTER CORPORATION
00:A0:DA	Integrated             # INTEGRATED SYSTEMS Technology, Inc.
00:A0:DB	FisherPayk             # FISHER & PAYKEL PRODUCTION
00:A0:DC	ONElectron             # O.N. ELECTRONIC CO., LTD.
00:A0:DD	Azonix                 # AZONIX CORPORATION
00:A0:DE	Yamaha                 # YAMAHA CORPORATION
00:A0:DF	StsTechnol             # STS TECHNOLOGIES, INC.
00:A0:E0	TennysonTe             # TENNYSON TECHNOLOGIES PTY LTD
00:A0:E1	WestportRe             # WESTPORT RESEARCH ASSOCIATES, INC.
00:A0:E2	KeisokuGik             # KEISOKU GIKEN CORP.
00:A0:E3	Xkl                    # XKL SYSTEMS CORP.
00:A0:E4	Optiquest
00:A0:E5	NhcCommuni             # NHC COMMUNICATIONS
00:A0:E6	Dialogic               # DIALOGIC CORPORATION
00:A0:E7	CentralDat             # CENTRAL DATA CORPORATION
00:A0:E8	ReutersHol             # REUTERS HOLDINGS PLC
00:A0:E9	Electronic             # ELECTRONIC RETAILING SYSTEMS INTERNATIONAL
00:A0:EA	Ethercom               # ETHERCOM CORP.
00:A0:EB	EncoreNetw             # Encore Networks
00:A0:EC	Transmitto             # TRANSMITTON LTD.
00:A0:ED	BrooksAuto             # Brooks Automation, Inc.
00:A0:EE	NashobaNet             # NASHOBA NETWORKS
00:A0:EF	Lucidata               # LUCIDATA LTD.
00:A0:F0	TorontoMic             # TORONTO MICROELECTRONICS INC.
00:A0:F1	Mti
00:A0:F2	InfotekCom             # INFOTEK COMMUNICATIONS, INC.
00:A0:F3	Staubli
00:A0:F4	Ge
00:A0:F5	Radguard               # RADGUARD LTD.
00:A0:F6	Autogas                # AutoGas Systems Inc.
00:A0:F7	VIComputer             # V.I COMPUTER CORP.
00:A0:F8	SymbolTech             # SYMBOL TECHNOLOGIES, INC.
00:A0:F9	BintecComm             # BINTEC COMMUNICATIONS GMBH
00:A0:FA	MarconiCom             # Marconi Communication GmbH
00:A0:FB	TorayEngin             # TORAY ENGINEERING CO., LTD.
00:A0:FC	ImageScien             # IMAGE SCIENCES, INC.
00:A0:FD	ScitexDigi             # SCITEX DIGITAL PRINTING, INC.
00:A0:FE	BostonTech             # BOSTON TECHNOLOGY, INC.
00:A0:FF	TellabsOpe             # TELLABS OPERATIONS, INC.
00:AA:00	Intel                  # INTEL CORPORATION
00:AA:01	Intel                  # INTEL CORPORATION
00:AA:02	Intel                  # INTEL CORPORATION
00:AA:3C	OlivettiTe             # OLIVETTI TELECOM SPA (OLTECO)
00:B0:09	GrassValle             # Grass Valley Group
00:B0:17	InfogearTe             # InfoGear Technology Corp.
00:B0:19	Casi-Rusco
00:B0:1C	WestportTe             # Westport Technologies
00:B0:1E	RanticLabs             # Rantic Labs, Inc.
00:B0:2A	Orsys                  # ORSYS GmbH
00:B0:2D	ViagateTec             # ViaGate Technologies, Inc.
00:B0:3B	HiqNetwork             # HiQ Networks
00:B0:48	MarconiCom             # Marconi Communications Inc.
00:B0:4A	Cisco                  # Cisco Systems, Inc.
00:B0:52	Intellon               # Intellon Corporation
00:B0:64	Cisco                  # Cisco Systems, Inc.
00:B0:69	HonewellOy             # Honewell Oy
00:B0:6D	JonesFutur             # Jones Futurex Inc.
00:B0:80	Mannesmann             # Mannesmann Ipulsys B.V.
00:B0:86	Locsoft                # LocSoft Limited
00:B0:8E	Cisco                  # Cisco Systems, Inc.
00:B0:91	Transmeta              # Transmeta Corp.
00:B0:94	Alaris                 # Alaris, Inc.
00:B0:9A	MorrowTech             # Morrow Technologies Corp.
00:B0:9D	PointGreyR             # Point Grey Research Inc.
00:B0:AC	Siae-Micro             # SIAE-Microelettronica S.p.A.
00:B0:AE	Symmetrico             # Symmetricom
00:B0:B3	Xstreamis              # Xstreamis PLC
00:B0:C2	Cisco                  # Cisco Systems, Inc.
00:B0:C7	TellabsOpe             # Tellabs Operations, Inc.
00:B0:CE	Technology             # TECHNOLOGY RESCUE
00:B0:D0	DellComput             # Dell Computer Corp.
00:B0:DB	Nextcell               # Nextcell, Inc.
00:B0:DF	ReliableDa             # Reliable Data Technology, Inc.
00:B0:E7	BritishFed             # British Federal Ltd.
00:B0:EC	Eacem
00:B0:EE	Ajile                  # Ajile Systems, Inc.
00:B0:F0	CalyNetwor             # CALY NETWORKS
00:B0:F5	NetworthTe             # NetWorth Technologies, Inc.
00:BA:C0	BiometricA             # Biometric Access Company
00:BB:01	Octothorpe             # OCTOTHORPE CORP.
00:BB:F0	Ungermann-             # UNGERMANN-BASS INC.
00:C0:00	Lanoptics              # LANOPTICS, LTD.
00:C0:01	DiatekPati             # DIATEK PATIENT MANAGMENT
00:C0:02	Sercomm                # SERCOMM CORPORATION
00:C0:03	GlobalnetC             # GLOBALNET COMMUNICATIONS
00:C0:04	JapanBusin             # JAPAN BUSINESS COMPUTER CO.LTD
00:C0:05	Livingston             # LIVINGSTON ENTERPRISES, INC.
00:C0:06	NipponAvio             # NIPPON AVIONICS CO., LTD.
00:C0:07	PinnacleDa             # PINNACLE DATA SYSTEMS, INC.
00:C0:08	SecoSrl                # SECO SRL
00:C0:09	KtTechnolo             # KT TECHNOLOGY (S) PTE LTD
00:C0:0A	MicroCraft             # MICRO CRAFT
00:C0:0B	Norcontrol             # NORCONTROL A.S.
00:C0:0C	ReliaTechn             # RELIA TECHNOLGIES
00:C0:0D	AdvancedLo             # ADVANCED LOGIC RESEARCH, INC.
00:C0:0E	Psitech                # PSITECH, INC.
00:C0:0F	QuantumSof             # QUANTUM SOFTWARE SYSTEMS LTD.
00:C0:10	HirakawaHe             # HIRAKAWA HEWTECH CORP.
00:C0:11	Interactiv             # INTERACTIVE COMPUTING DEVICES
00:C0:12	Netspan                # NETSPAN CORPORATION
00:C0:13	Netrix
00:C0:14	Telematics             # TELEMATICS CALABASAS INT'L,INC
00:C0:15	NewMedia               # NEW MEDIA CORPORATION
00:C0:16	Electronic             # ELECTRONIC THEATRE CONTROLS
00:C0:17	ForteNetwo             # FORTE NETWORKS
00:C0:18	Lanart                 # LANART CORPORATION
00:C0:19	LeapTechno             # LEAP TECHNOLOGY, INC.
00:C0:1A	Corometric             # COROMETRICS MEDICAL SYSTEMS
00:C0:1B	SocketComm             # SOCKET COMMUNICATIONS, INC.
00:C0:1C	InterlinkC             # INTERLINK COMMUNICATIONS LTD.
00:C0:1D	GrandJunct             # GRAND JUNCTION NETWORKS, INC.
00:C0:1E	LaFrancais             # LA FRANCAISE DES JEUX
00:C0:1F	SERCEL                 # S.E.R.C.E.L.
00:C0:20	ArcoElectr             # ARCO ELECTRONIC, CONTROL LTD.
00:C0:21	Netexpress
00:C0:22	Lasermaste             # LASERMASTER TECHNOLOGIES, INC.
00:C0:23	Tutankhamo             # TUTANKHAMON ELECTRONICS
00:C0:24	EdenSistem             # EDEN SISTEMAS DE COMPUTACAO SA
00:C0:25	Dataproduc             # DATAPRODUCTS CORPORATION
00:C0:26	LansTechno             # LANS TECHNOLOGY CO., LTD.
00:C0:27	Cipher                 # CIPHER SYSTEMS, INC.
00:C0:28	Jasco                  # JASCO CORPORATION
00:C0:29	NexansDeut             # Nexans Deutschland AG - ANS
00:C0:2A	OhkuraElec             # OHKURA ELECTRIC CO., LTD.
00:C0:2B	GerloffGes             # GERLOFF GESELLSCHAFT FUR
00:C0:2C	CentrumCom             # CENTRUM COMMUNICATIONS, INC.
00:C0:2D	FujiPhotoF             # FUJI PHOTO FILM CO., LTD.
00:C0:2E	Netwiz
00:C0:2F	Okuma                  # OKUMA CORPORATION
00:C0:30	Integrated             # INTEGRATED ENGINEERING B. V.
00:C0:31	DesignRese             # DESIGN RESEARCH SYSTEMS, INC.
00:C0:32	I-Cubed                # I-CUBED LIMITED
00:C0:33	TelebitCom             # TELEBIT COMMUNICATIONS APS
00:C0:34	Transactio             # TRANSACTION NETWORK
00:C0:35	Quintar                # QUINTAR COMPANY
00:C0:36	RaytechEle             # RAYTECH ELECTRONIC CORP.
00:C0:37	Dynatem
00:C0:38	RasterImag             # RASTER IMAGE PROCESSING SYSTEM
00:C0:39	TeridianSe             # Teridian Semiconductor Corporation
00:C0:3A	Men-MikroE             # MEN-MIKRO ELEKTRONIK GMBH
00:C0:3B	Multiacces             # MULTIACCESS COMPUTING CORP.
00:C0:3C	TowerTechS             # TOWER TECH S.R.L.
00:C0:3D	WiesemannT             # WIESEMANN & THEIS GMBH
00:C0:3E	FaGebrHell             # FA. GEBR. HELLER GMBH
00:C0:3F	StoresAuto             # STORES AUTOMATED SYSTEMS, INC.
00:C0:40	Ecci
00:C0:41	DigitalTra             # DIGITAL TRANSMISSION SYSTEMS
00:C0:42	Datalux                # DATALUX CORP.
00:C0:43	Stratacom
00:C0:44	Emcom                  # EMCOM CORPORATION
00:C0:45	Isolation              # ISOLATION SYSTEMS, LTD.
00:C0:46	Kemitron               # KEMITRON LTD.
00:C0:47	Unimicro               # UNIMICRO SYSTEMS, INC.
00:C0:48	BayTechnic             # BAY TECHNICAL ASSOCIATES
00:C0:49	USRobotics             # U.S. ROBOTICS, INC.
00:C0:4A	Group2000              # GROUP 2000 AG
00:C0:4B	CreativeMi             # CREATIVE MICROSYSTEMS
00:C0:4C	Department             # DEPARTMENT OF FOREIGN AFFAIRS
00:C0:4D	Mitec                  # MITEC, INC.
00:C0:4E	Comtrol                # COMTROL CORPORATION
00:C0:4F	DellComput             # DELL COMPUTER CORPORATION
00:C0:50	ToyoDenkiS             # TOYO DENKI SEIZO K.K.
00:C0:51	AdvancedIn             # ADVANCED INTEGRATION RESEARCH
00:C0:52	Burr-Brown
00:C0:53	ConcertoSo             # Concerto Software
00:C0:54	NetworkPer             # NETWORK PERIPHERALS, LTD.
00:C0:55	ModularCom             # MODULAR COMPUTING TECHNOLOGIES
00:C0:56	Somelec
00:C0:57	MycoElectr             # MYCO ELECTRONICS
00:C0:58	Dataexpert             # DATAEXPERT CORP.
00:C0:59	NipponDens             # NIPPON DENSO CO., LTD.
00:C0:5A	SemaphoreC             # SEMAPHORE COMMUNICATIONS CORP.
00:C0:5B	NetworksNo             # NETWORKS NORTHWEST, INC.
00:C0:5C	Elonex                 # ELONEX PLC
00:C0:5D	L&NTechnol             # L&N TECHNOLOGIES
00:C0:5E	Vari-Lite              # VARI-LITE, INC.
00:C0:5F	Fine-Pal               # FINE-PAL COMPANY LIMITED
00:C0:60	IdScandina             # ID SCANDINAVIA AS
00:C0:61	Solectek               # SOLECTEK CORPORATION
00:C0:62	ImpulseTec             # IMPULSE TECHNOLOGY
00:C0:63	MorningSta             # MORNING STAR TECHNOLOGIES, INC
00:C0:64	GeneralDat             # GENERAL DATACOMM IND. INC.
00:C0:65	ScopeCommu             # SCOPE COMMUNICATIONS, INC.
00:C0:66	Docupoint              # DOCUPOINT, INC.
00:C0:67	UnitedBarc             # UNITED BARCODE INDUSTRIES
00:C0:68	PhilipDrak             # PHILIP DRAKE ELECTRONICS LTD.
00:C0:69	AxxceleraB             # Axxcelera Broadband Wireless
00:C0:6A	Zahner-Ele             # ZAHNER-ELEKTRIK GMBH & CO. KG
00:C0:6B	OsiPlus                # OSI PLUS CORPORATION
00:C0:6C	SvecComput             # SVEC COMPUTER CORP.
00:C0:6D	BocaResear             # BOCA RESEARCH, INC.
00:C0:6E	HaftTechno             # HAFT TECHNOLOGY, INC.
00:C0:6F	Komatsu                # KOMATSU LTD.
00:C0:70	SectraSecu             # SECTRA SECURE-TRANSMISSION AB
00:C0:71	AreanexCom             # AREANEX COMMUNICATIONS, INC.
00:C0:72	Knx                    # KNX LTD.
00:C0:73	Xedia                  # XEDIA CORPORATION
00:C0:74	ToyodaAuto             # TOYODA AUTOMATIC LOOM
00:C0:75	Xante                  # XANTE CORPORATION
00:C0:76	I-DataInte             # I-DATA INTERNATIONAL A-S
00:C0:77	DaewooTele             # DAEWOO TELECOM LTD.
00:C0:78	ComputerEn             # COMPUTER SYSTEMS ENGINEERING
00:C0:79	Fonsys                 # FONSYS CO.,LTD.
00:C0:7A	PrivaBV                # PRIVA B.V.
00:C0:7B	AscendComm             # ASCEND COMMUNICATIONS, INC.
00:C0:7C	HightechIn             # HIGHTECH INFORMATION
00:C0:7D	RiscDevelo             # RISC DEVELOPMENTS LTD.
00:C0:7E	KubotaElec             # KUBOTA CORPORATION ELECTRONIC
00:C0:7F	NuponCompu             # NUPON COMPUTING CORP.
00:C0:80	Netstar                # NETSTAR, INC.
00:C0:81	Metrodata              # METRODATA LTD.
00:C0:82	MooreProdu             # MOORE PRODUCTS CO.
00:C0:83	TraceMount             # TRACE MOUNTAIN PRODUCTS, INC.
00:C0:84	DataLink               # DATA LINK CORP. LTD.
00:C0:85	Electronic             # ELECTRONICS FOR IMAGING, INC.
00:C0:86	Lynk                   # THE LYNK CORPORATION
00:C0:87	UunetTechn             # UUNET TECHNOLOGIES, INC.
00:C0:88	EkfElektro             # EKF ELEKTRONIK GMBH
00:C0:89	TelindusDi             # TELINDUS DISTRIBUTION
00:C0:8A	Lauterbach             # LAUTERBACH DATENTECHNIK GMBH
00:C0:8B	RisqModula             # RISQ MODULAR SYSTEMS, INC.
00:C0:8C	Performanc             # PERFORMANCE TECHNOLOGIES, INC.
00:C0:8D	TronixProd             # TRONIX PRODUCT DEVELOPMENT
00:C0:8E	NetworkInf             # NETWORK INFORMATION TECHNOLOGY
00:C0:8F	Matsushita             # MATSUSHITA ELECTRIC WORKS, LTD
00:C0:90	PraimSRL               # PRAIM S.R.L.
00:C0:91	JabilCircu             # JABIL CIRCUIT, INC.
00:C0:92	MennenMedi             # MENNEN MEDICAL INC.
00:C0:93	AltaResear             # ALTA RESEARCH CORP.
00:C0:94	Vmx                    # VMX INC.
00:C0:95	Znyx
00:C0:96	Tamura                 # TAMURA CORPORATION
00:C0:97	ArchipelSa             # ARCHIPEL SA
00:C0:98	ChuntexEle             # CHUNTEX ELECTRONIC CO., LTD.
00:C0:99	YoshikiInd             # YOSHIKI INDUSTRIAL CO.,LTD.
00:C0:9A	Photonics              # PHOTONICS CORPORATION
00:C0:9B	RelianceCo             # RELIANCE COMM/TEC, R-TEC
00:C0:9C	ToaElectro             # TOA ELECTRONIC LTD.
00:C0:9D	Distribute             # DISTRIBUTED SYSTEMS INT'L, INC
00:C0:9E	CacheCompu             # CACHE COMPUTERS, INC.
00:C0:9F	QuantaComp             # QUANTA COMPUTER, INC.
00:C0:A0	AdvanceMic             # ADVANCE MICRO RESEARCH, INC.
00:C0:A1	TokyoDensh             # TOKYO DENSHI SEKEI CO.
00:C0:A2	Intermediu             # INTERMEDIUM A/S
00:C0:A3	DualEnterp             # DUAL ENTERPRISES CORPORATION
00:C0:A4	UnigrafOy              # UNIGRAF OY
00:C0:A5	DickensDat             # DICKENS DATA SYSTEMS
00:C0:A6	ExicomAust             # EXICOM AUSTRALIA PTY. LTD
00:C0:A7	Seel                   # SEEL LTD.
00:C0:A8	Gvc                    # GVC CORPORATION
00:C0:A9	BarronMcca             # BARRON MCCANN LTD.
00:C0:AA	SiliconVal             # SILICON VALLEY COMPUTER
00:C0:AB	Telco                  # Telco Systems, Inc.
00:C0:AC	GambitComp             # GAMBIT COMPUTER COMMUNICATIONS
00:C0:AD	MarbenComm             # MARBEN COMMUNICATION SYSTEMS
00:C0:AE	TowercomDb             # TOWERCOM CO. INC. DBA PC HOUSE
00:C0:AF	Teklogix               # TEKLOGIX INC.
00:C0:B0	GccTechnol             # GCC TECHNOLOGIES,INC.
00:C0:B1	GeniusNet              # GENIUS NET CO.
00:C0:B2	Norand                 # NORAND CORPORATION
00:C0:B3	ComstatDat             # COMSTAT DATACOMM CORPORATION
00:C0:B4	MysonTechn             # MYSON TECHNOLOGY, INC.
00:C0:B5	CorporateN             # CORPORATE NETWORK SYSTEMS,INC.
00:C0:B6	SnapApplia             # Snap Appliance, Inc.
00:C0:B7	AmericanPo             # AMERICAN POWER CONVERSION CORP
00:C0:B8	FraserSHil             # FRASER'S HILL LTD.
00:C0:B9	FunkSoftwa             # FUNK SOFTWARE, INC.
00:C0:BA	Netvantage
00:C0:BB	ForvalCrea             # FORVAL CREATIVE, INC.
00:C0:BC	TelecomAus             # TELECOM AUSTRALIA/CSSC
00:C0:BD	InexTechno             # INEX TECHNOLOGIES, INC.
00:C0:BE	Alcatel-Se             # ALCATEL - SEL
00:C0:BF	Technology             # TECHNOLOGY CONCEPTS, LTD.
00:C0:C0	ShoreMicro             # SHORE MICROSYSTEMS, INC.
00:C0:C1	Quad/Graph             # QUAD/GRAPHICS, INC.
00:C0:C2	InfiniteNe             # INFINITE NETWORKS LTD.
00:C0:C3	AcusonComp             # ACUSON COMPUTED SONOGRAPHY
00:C0:C4	ComputerOp             # COMPUTER OPERATIONAL
00:C0:C5	SidInforma             # SID INFORMATICA
00:C0:C6	PersonalMe             # PERSONAL MEDIA CORP.
00:C0:C7	SparktrumM             # SPARKTRUM MICROSYSTEMS, INC.
00:C0:C8	MicroByteP             # MICRO BYTE PTY. LTD.
00:C0:C9	ElsagBaile             # ELSAG BAILEY PROCESS
00:C0:CA	Alfa                   # ALFA, INC.
00:C0:CB	ControlTec             # CONTROL TECHNOLOGY CORPORATION
00:C0:CC	Telescienc             # TELESCIENCES CO SYSTEMS, INC.
00:C0:CD	ComeltaSA              # COMELTA, S.A.
00:C0:CE	CeiEnginee             # CEI SYSTEMS & ENGINEERING PTE
00:C0:CF	ImatranVoi             # IMATRAN VOIMA OY
00:C0:D0	RatocSyste             # RATOC SYSTEM INC.
00:C0:D1	ComtreeTec             # COMTREE TECHNOLOGY CORPORATION
00:C0:D2	Syntellect             # SYNTELLECT, INC.
00:C0:D3	OlympusIma             # OLYMPUS IMAGE SYSTEMS, INC.
00:C0:D4	AxonNetwor             # AXON NETWORKS, INC.
00:C0:D5	QuancomEle             # QUANCOM ELECTRONIC GMBH
00:C0:D6	J1                     # J1 SYSTEMS, INC.
00:C0:D7	TaiwanTrad             # TAIWAN TRADING CENTER DBA
00:C0:D8	UniversalD             # UNIVERSAL DATA SYSTEMS
00:C0:D9	QuinteNetw             # QUINTE NETWORK CONFIDENTIALITY
00:C0:DA	Nice                   # NICE SYSTEMS LTD.
00:C0:DB	IpcPte                 # IPC CORPORATION (PTE) LTD.
00:C0:DC	EosTechnol             # EOS TECHNOLOGIES, INC.
00:C0:DD	Qlogic                 # QLogic Corporation
00:C0:DE	Zcomm                  # ZCOMM, INC.
00:C0:DF	Kye                    # KYE Systems Corp.
00:C0:E0	DscCommuni             # DSC COMMUNICATION CORP.
00:C0:E1	SonicSolut             # SONIC SOLUTIONS
00:C0:E2	Calcomp                # CALCOMP, INC.
00:C0:E3	OsitechCom             # OSITECH COMMUNICATIONS, INC.
00:C0:E4	SiemensBui             # SIEMENS BUILDING
00:C0:E5	GespacSA               # GESPAC, S.A.
00:C0:E6	Verilink               # Verilink Corporation
00:C0:E7	Fiberdata              # FIBERDATA AB
00:C0:E8	Plexcom                # PLEXCOM, INC.
00:C0:E9	OakSolutio             # OAK SOLUTIONS, LTD.
00:C0:EA	ArrayTechn             # ARRAY TECHNOLOGY LTD.
00:C0:EB	SehCompute             # SEH COMPUTERTECHNIK GMBH
00:C0:EC	DauphinTec             # DAUPHIN TECHNOLOGY
00:C0:ED	UsArmyElec             # US ARMY ELECTRONIC
00:C0:EE	Kyocera                # KYOCERA CORPORATION
00:C0:EF	Abit                   # ABIT CORPORATION
00:C0:F0	KingstonTe             # KINGSTON TECHNOLOGY CORP.
00:C0:F1	ShinkoElec             # SHINKO ELECTRIC CO., LTD.
00:C0:F2	Transition             # TRANSITION NETWORKS
00:C0:F3	NetworkCom             # NETWORK COMMUNICATIONS CORP.
00:C0:F4	InterlinkS             # INTERLINK SYSTEM CO., LTD.
00:C0:F5	Metacomp               # METACOMP, INC.
00:C0:F6	CelanTechn             # CELAN TECHNOLOGY INC.
00:C0:F7	EngageComm             # ENGAGE COMMUNICATION, INC.
00:C0:F8	AboutCompu             # ABOUT COMPUTING INC.
00:C0:F9	MotorolaEm             # Motorola Embedded Computing Group
00:C0:FA	CanaryComm             # CANARY COMMUNICATIONS, INC.
00:C0:FB	AdvancedTe             # ADVANCED TECHNOLOGY LABS
00:C0:FC	ElasticRea             # ELASTIC REALITY, INC.
00:C0:FD	Prosum
00:C0:FE	AptecCompu             # APTEC COMPUTER SYSTEMS, INC.
00:C0:FF	DotHill                # DOT HILL SYSTEMS CORPORATION
00:CB:BD	CambridgeB             # Cambridge Broadband Ltd.
00:CF:1C	Communicat             # COMMUNICATION MACHINERY CORP.
00:D0:00	FerranScie             # FERRAN SCIENTIFIC, INC.
00:D0:01	VstTechnol             # VST TECHNOLOGIES, INC.
00:D0:02	Ditech                 # DITECH CORPORATION
00:D0:03	ComdaEnter             # COMDA ENTERPRISES CORP.
00:D0:04	Pentacom               # PENTACOM LTD.
00:D0:05	ZhsZeitman             # ZHS ZEITMANAGEMENTSYSTEME
00:D0:06	Cisco                  # CISCO SYSTEMS, INC.
00:D0:07	MicAssocia             # MIC ASSOCIATES, INC.
00:D0:08	Mactell                # MACTELL CORPORATION
00:D0:09	HsingTechE             # HSING TECH. ENTERPRISE CO. LTD
00:D0:0A	LanaccessT             # LANACCESS TELECOM S.A.
00:D0:0B	RhkTechnol             # RHK TECHNOLOGY, INC.
00:D0:0C	SnijderMic             # SNIJDER MICRO SYSTEMS
00:D0:0D	Micromerit             # MICROMERITICS INSTRUMENT
00:D0:0E	Pluris                 # PLURIS, INC.
00:D0:0F	SpeechDesi             # SPEECH DESIGN GMBH
00:D0:10	Convergent             # CONVERGENT NETWORKS, INC.
00:D0:11	PrismVideo             # PRISM VIDEO, INC.
00:D0:12	Gateworks              # GATEWORKS CORP.
00:D0:13	PrimexAero             # PRIMEX AEROSPACE COMPANY
00:D0:14	Root                   # ROOT, INC.
00:D0:15	UnivexMicr             # UNIVEX MICROTECHNOLOGY CORP.
00:D0:16	ScmMicrosy             # SCM MICROSYSTEMS, INC.
00:D0:17	SyntechInf             # SYNTECH INFORMATION CO., LTD.
00:D0:18	QwesCom                # QWES. COM, INC.
00:D0:19	DainipponS             # DAINIPPON SCREEN CORPORATE
00:D0:1A	UrmetTlcSP             # URMET  TLC S.P.A.
00:D0:1B	MimakiEngi             # MIMAKI ENGINEERING CO., LTD.
00:D0:1C	SbsTechnol             # SBS TECHNOLOGIES,
00:D0:1D	FurunoElec             # FURUNO ELECTRIC CO., LTD.
00:D0:1E	Pingtel                # PINGTEL CORP.
00:D0:1F	CtamPty                # CTAM PTY. LTD.
00:D0:20	AimSystem              # AIM SYSTEM, INC.
00:D0:21	RegentElec             # REGENT ELECTRONICS CORP.
00:D0:22	Incredible             # INCREDIBLE TECHNOLOGIES, INC.
00:D0:23	Infortrend             # INFORTREND TECHNOLOGY, INC.
00:D0:24	Cognex                 # Cognex Corporation
00:D0:25	Xrosstech              # XROSSTECH, INC.
00:D0:26	Hirschmann             # HIRSCHMANN AUSTRIA GMBH
00:D0:27	AppliedAut             # APPLIED AUTOMATION, INC.
00:D0:28	OmneonVide             # OMNEON VIDEO NETWORKS
00:D0:29	WakefernFo             # WAKEFERN FOOD CORPORATION
00:D0:2A	Voxent                 # Voxent Systems Ltd.
00:D0:2B	Jetcell                # JETCELL, INC.
00:D0:2C	CampbellSc             # CAMPBELL SCIENTIFIC, INC.
00:D0:2D	Ademco
00:D0:2E	Communicat             # COMMUNICATION AUTOMATION CORP.
00:D0:2F	VlsiTechno             # VLSI TECHNOLOGY INC.
00:D0:30	Safetran               # SAFETRAN SYSTEMS CORP.
00:D0:31	Industrial             # INDUSTRIAL LOGIC CORPORATION
00:D0:32	YanoElectr             # YANO ELECTRIC CO., LTD.
00:D0:33	DalianDaxi             # DALIAN DAXIAN NETWORK
00:D0:34	Ormec                  # ORMEC SYSTEMS CORP.
00:D0:35	BehaviorTe             # BEHAVIOR TECH. COMPUTER CORP.
00:D0:36	Technology             # TECHNOLOGY ATLANTA CORP.
00:D0:37	Philips-Dv             # PHILIPS-DVS-LO BDR
00:D0:38	Fivemere               # FIVEMERE, LTD.
00:D0:39	Utilicom               # UTILICOM, INC.
00:D0:3A	Zoneworx               # ZONEWORX, INC.
00:D0:3B	VisionProd             # VISION PRODUCTS PTY. LTD.
00:D0:3C	Vieo                   # Vieo, Inc.
00:D0:3D	GalileoTec             # GALILEO TECHNOLOGY, LTD.
00:D0:3E	Rocketchip             # ROCKETCHIPS, INC.
00:D0:3F	AmericanCo             # AMERICAN COMMUNICATION
00:D0:40	Sysmate                # SYSMATE CO., LTD.
00:D0:41	AmigoTechn             # AMIGO TECHNOLOGY CO., LTD.
00:D0:42	MahloUg                # MAHLO GMBH & CO. UG
00:D0:43	ZonalRetai             # ZONAL RETAIL DATA SYSTEMS
00:D0:44	AlidianNet             # ALIDIAN NETWORKS, INC.
00:D0:45	Kvaser                 # KVASER AB
00:D0:46	DolbyLabor             # DOLBY LABORATORIES, INC.
00:D0:47	XnTechnolo             # XN TECHNOLOGIES
00:D0:48	Ecton                  # ECTON, INC.
00:D0:49	Impresstek             # IMPRESSTEK CO., LTD.
00:D0:4A	PresenceTe             # PRESENCE TECHNOLOGY GMBH
00:D0:4B	LaCieGroup             # LA CIE GROUP S.A.
00:D0:4C	EurotelTel             # EUROTEL TELECOM LTD.
00:D0:4D	DivOfResea             # DIV OF RESEARCH & STATISTICS
00:D0:4E	Logibag
00:D0:4F	Bitronics              # BITRONICS, INC.
00:D0:50	Iskratel
00:D0:51	O2Micro                # O2 MICRO, INC.
00:D0:52	AscendComm             # ASCEND COMMUNICATIONS, INC.
00:D0:53	Connected              # CONNECTED SYSTEMS
00:D0:54	SasInstitu             # SAS INSTITUTE INC.
00:D0:55	Kathrein-W             # KATHREIN-WERKE KG
00:D0:56	Somat                  # SOMAT CORPORATION
00:D0:57	Ultrak                 # ULTRAK, INC.
00:D0:58	Cisco                  # CISCO SYSTEMS, INC.
00:D0:59	AmbitMicro             # AMBIT MICROSYSTEMS CORP.
00:D0:5A	Symbionics             # SYMBIONICS, LTD.
00:D0:5B	AcroloopMo             # ACROLOOP MOTION CONTROL
00:D0:5C	Technotren             # TECHNOTREND SYSTEMTECHNIK GMBH
00:D0:5D	Intelliwor             # INTELLIWORXX, INC.
00:D0:5E	Stratabeam             # STRATABEAM TECHNOLOGY, INC.
00:D0:5F	Valcom                 # VALCOM, INC.
00:D0:60	PanasonicE             # PANASONIC EUROPEAN
00:D0:61	TremonEnte             # TREMON ENTERPRISES CO., LTD.
00:D0:62	Digigram
00:D0:63	Cisco                  # CISCO SYSTEMS, INC.
00:D0:64	Multitel
00:D0:65	TokoElectr             # TOKO ELECTRIC
00:D0:66	WintrissEn             # WINTRISS ENGINEERING CORP.
00:D0:67	CampioComm             # CAMPIO COMMUNICATIONS
00:D0:68	Iwill                  # IWILL CORPORATION
00:D0:69	Technologi             # TECHNOLOGIC SYSTEMS
00:D0:6A	Linkup                 # LINKUP SYSTEMS CORPORATION
00:D0:6B	SrTelecom              # SR TELECOM INC.
00:D0:6C	Sharewave              # SHAREWAVE, INC.
00:D0:6D	Acrison                # ACRISON, INC.
00:D0:6E	TrendviewR             # TRENDVIEW RECORDERS LTD.
00:D0:6F	KmcControl             # KMC CONTROLS
00:D0:70	LongWellEl             # LONG WELL ELECTRONICS CORP.
00:D0:71	Echelon                # ECHELON CORP.
00:D0:72	Broadlogic
00:D0:73	AcnAdvance             # ACN ADVANCED COMMUNICATIONS
00:D0:74	Taqua                  # TAQUA SYSTEMS, INC.
00:D0:75	AlarisMedi             # ALARIS MEDICAL SYSTEMS, INC.
00:D0:76	MerrillLyn             # MERRILL LYNCH & CO., INC.
00:D0:77	LucentTech             # LUCENT TECHNOLOGIES
00:D0:78	EltexOfSwe             # ELTEX OF SWEDEN AB
00:D0:79	Cisco                  # CISCO SYSTEMS, INC.
00:D0:7A	AmaquestCo             # AMAQUEST COMPUTER CORP.
00:D0:7B	ComcamInte             # COMCAM INTERNATIONAL LTD.
00:D0:7C	KoyoElectr             # KOYO ELECTRONICS INC. CO.,LTD.
00:D0:7D	CosineComm             # COSINE COMMUNICATIONS
00:D0:7E	Keycorp                # KEYCORP LTD.
00:D0:7F	StrategyTe             # STRATEGY & TECHNOLOGY, LIMITED
00:D0:80	Exabyte                # EXABYTE CORPORATION
00:D0:81	RealTimeDe             # REAL TIME DEVICES USA, INC.
00:D0:82	Iowave                 # IOWAVE INC.
00:D0:83	Invertex               # INVERTEX, INC.
00:D0:84	Nexcomm                # NEXCOMM SYSTEMS, INC.
00:D0:85	OtisElevat             # OTIS ELEVATOR COMPANY
00:D0:86	Foveon                 # FOVEON, INC.
00:D0:87	Microfirst             # MICROFIRST INC.
00:D0:88	TerayonCom             # Terayon Communications Systems
00:D0:89	Dynacolor              # DYNACOLOR, INC.
00:D0:8A	PhotronUsa             # PHOTRON USA
00:D0:8B	Adva                   # ADVA Limited
00:D0:8C	GenoaTechn             # GENOA TECHNOLOGY, INC.
00:D0:8D	PhoenixGro             # PHOENIX GROUP, INC.
00:D0:8E	Nvision                # NVISION INC.
00:D0:8F	ArdentTech             # ARDENT TECHNOLOGIES, INC.
00:D0:90	Cisco                  # CISCO SYSTEMS, INC.
00:D0:91	Smartsan               # SMARTSAN SYSTEMS, INC.
00:D0:92	GlenayreWe             # GLENAYRE WESTERN MULTIPLEX
00:D0:93	Tq-Compone             # TQ - COMPONENTS GMBH
00:D0:94	TimelineVi             # TIMELINE VISTA, INC.
00:D0:95	AlcatelNor             # Alcatel North America ESD
00:D0:96	3comEurope             # 3COM EUROPE LTD.
00:D0:97	Cisco                  # CISCO SYSTEMS, INC.
00:D0:98	PhotonDyna             # Photon Dynamics Canada Inc.
00:D0:99	ElcardOy               # ELCARD OY
00:D0:9A	Filanet                # FILANET CORPORATION
00:D0:9B	Spectel                # SPECTEL LTD.
00:D0:9C	KapadiaCom             # KAPADIA COMMUNICATIONS
00:D0:9D	VerisIndus             # VERIS INDUSTRIES
00:D0:9E	2wire                  # 2WIRE, INC.
00:D0:9F	NovtekTest             # NOVTEK TEST SYSTEMS
00:D0:A0	MipsDenmar             # MIPS DENMARK
00:D0:A1	OskarVierl             # OSKAR VIERLING GMBH + CO. KG
00:D0:A2	Integrated             # INTEGRATED DEVICE
00:D0:A3	VocalData              # VOCAL DATA, INC.
00:D0:A4	AlantroCom             # ALANTRO COMMUNICATIONS
00:D0:A5	AmericanAr             # AMERICAN ARIUM
00:D0:A6	LanbirdTec             # LANBIRD TECHNOLOGY CO., LTD.
00:D0:A7	TokyoSokki             # TOKYO SOKKI KENKYUJO CO., LTD.
00:D0:A8	NetworkEng             # NETWORK ENGINES, INC.
00:D0:A9	ShinanoKen             # SHINANO KENSHI CO., LTD.
00:D0:AA	ChaseCommu             # CHASE COMMUNICATIONS
00:D0:AB	Deltakabel             # DELTAKABEL TELECOM CV
00:D0:AC	GraysonWir             # GRAYSON WIRELESS
00:D0:AD	TlIndustri             # TL INDUSTRIES
00:D0:AE	OresisComm             # ORESIS COMMUNICATIONS, INC.
00:D0:AF	Cutler-Ham             # CUTLER-HAMMER, INC.
00:D0:B0	Bitswitch              # BITSWITCH LTD.
00:D0:B1	OmegaElect             # OMEGA ELECTRONICS SA
00:D0:B2	Xiotech                # XIOTECH CORPORATION
00:D0:B3	DrsFlightS             # DRS FLIGHT SAFETY AND
00:D0:B4	Katsujima              # KATSUJIMA CO., LTD.
00:D0:B5	IpricotFor             # IPricot formerly DotCom
00:D0:B6	CrescentNe             # CRESCENT NETWORKS, INC.
00:D0:B7	Intel                  # INTEL CORPORATION
00:D0:B8	Iomega                 # Iomega Corporation
00:D0:B9	MicrotekIn             # MICROTEK INTERNATIONAL, INC.
00:D0:BA	Cisco                  # CISCO SYSTEMS, INC.
00:D0:BB	Cisco                  # CISCO SYSTEMS, INC.
00:D0:BC	Cisco                  # CISCO SYSTEMS, INC.
00:D0:BD	Sican                  # SICAN GMBH
00:D0:BE	Emutec                 # EMUTEC INC.
00:D0:BF	PivotalTec             # PIVOTAL TECHNOLOGIES
00:D0:C0	Cisco                  # CISCO SYSTEMS, INC.
00:D0:C1	HarmonicDa             # HARMONIC DATA SYSTEMS, LTD.
00:D0:C2	BalthazarT             # BALTHAZAR TECHNOLOGY AB
00:D0:C3	VividTechn             # VIVID TECHNOLOGY PTE, LTD.
00:D0:C4	Teratech               # TERATECH CORPORATION
00:D0:C5	Computatio             # COMPUTATIONAL SYSTEMS, INC.
00:D0:C6	ThomasBett             # THOMAS & BETTS CORP.
00:D0:C7	Pathway                # PATHWAY, INC.
00:D0:C8	I/OConsult             # I/O CONSULTING A/S
00:D0:C9	Advantech              # ADVANTECH CO., LTD.
00:D0:CA	IntrinsycS             # INTRINSYC SOFTWARE INC.
00:D0:CB	Dasan                  # DASAN CO., LTD.
00:D0:CC	Technologi             # TECHNOLOGIES LYRE INC.
00:D0:CD	AtanTechno             # ATAN TECHNOLOGY INC.
00:D0:CE	AsystElect             # ASYST ELECTRONIC
00:D0:CF	MoretonBay             # MORETON BAY
00:D0:D0	ZhongxingT             # ZHONGXING TELECOM LTD.
00:D0:D1	Sirocco                # SIROCCO SYSTEMS, INC.
00:D0:D2	Epilog                 # EPILOG CORPORATION
00:D0:D3	Cisco                  # CISCO SYSTEMS, INC.
00:D0:D4	V-Bits                 # V-BITS, INC.
00:D0:D5	Grundig                # GRUNDIG AG
00:D0:D6	AethraTele             # AETHRA TELECOMUNICAZIONI
00:D0:D7	B2c2                   # B2C2, INC.
00:D0:D8	3com                   # 3Com Corporation
00:D0:D9	DedicatedM             # DEDICATED MICROCOMPUTERS
00:D0:DA	TaicomData             # TAICOM DATA SYSTEMS CO., LTD.
00:D0:DB	McquayInte             # MCQUAY INTERNATIONAL
00:D0:DC	ModularMin             # MODULAR MINING SYSTEMS, INC.
00:D0:DD	SunriseTel             # SUNRISE TELECOM, INC.
00:D0:DE	PhilipsMul             # PHILIPS MULTIMEDIA NETWORK
00:D0:DF	KuzumiElec             # KUZUMI ELECTRONICS, INC.
00:D0:E0	DooinElect             # DOOIN ELECTRONICS CO.
00:D0:E1	AvionitekI             # AVIONITEK ISRAEL INC.
00:D0:E2	MrtMicro               # MRT MICRO, INC.
00:D0:E3	Ele-ChemEn             # ELE-CHEM ENGINEERING CO., LTD.
00:D0:E4	Cisco                  # CISCO SYSTEMS, INC.
00:D0:E5	Solidum                # SOLIDUM SYSTEMS CORP.
00:D0:E6	Ibond                  # IBOND INC.
00:D0:E7	VconTeleco             # VCON TELECOMMUNICATION LTD.
00:D0:E8	MacSystem              # MAC SYSTEM CO., LTD.
00:D0:E9	AdvantageC             # ADVANTAGE CENTURY
00:D0:EA	NextoneCom             # NEXTONE COMMUNICATIONS, INC.
00:D0:EB	LighteraNe             # LIGHTERA NETWORKS, INC.
00:D0:EC	NakayoTele             # NAKAYO TELECOMMUNICATIONS, INC
00:D0:ED	Xiox
00:D0:EE	Dictaphone             # DICTAPHONE CORPORATION
00:D0:EF	Igt
00:D0:F0	ConvisionT             # CONVISION TECHNOLOGY GMBH
00:D0:F1	SegaEnterp             # SEGA ENTERPRISES, LTD.
00:D0:F2	MontereyNe             # MONTEREY NETWORKS
00:D0:F3	SolariDiUd             # SOLARI DI UDINE SPA
00:D0:F4	Carinthian             # CARINTHIAN TECH INSTITUTE
00:D0:F5	OrangeMicr             # ORANGE MICRO, INC.
00:D0:F6	AlcatelCan             # Alcatel Canada
00:D0:F7	NextNets               # NEXT NETS CORPORATION
00:D0:F8	FujianStar             # FUJIAN STAR TERMINAL
00:D0:F9	AcuteCommu             # ACUTE COMMUNICATIONS CORP.
00:D0:FA	RacalGuard             # RACAL GUARDATA
00:D0:FB	TekMicrosy             # TEK MICROSYSTEMS, INCORPORATED
00:D0:FC	GraniteMic             # GRANITE MICROSYSTEMS
00:D0:FD	OptimaTele             # OPTIMA TELE.COM, INC.
00:D0:FE	AstralPoin             # ASTRAL POINT
00:D0:FF	Cisco                  # CISCO SYSTEMS, INC.
00:DD:00	Ungermann-             # UNGERMANN-BASS INC.
00:DD:01	Ungermann-             # UNGERMANN-BASS INC.
00:DD:02	Ungermann-             # UNGERMANN-BASS INC.
00:DD:03	Ungermann-             # UNGERMANN-BASS INC.
00:DD:04	Ungermann-             # UNGERMANN-BASS INC.
00:DD:05	Ungermann-             # UNGERMANN-BASS INC.
00:DD:06	Ungermann-             # UNGERMANN-BASS INC.
00:DD:07	Ungermann-             # UNGERMANN-BASS INC.
00:DD:08	Ungermann-             # UNGERMANN-BASS INC.
00:DD:09	Ungermann-             # UNGERMANN-BASS INC.
00:DD:0A	Ungermann-             # UNGERMANN-BASS INC.
00:DD:0B	Ungermann-             # UNGERMANN-BASS INC.
00:DD:0C	Ungermann-             # UNGERMANN-BASS INC.
00:DD:0D	Ungermann-             # UNGERMANN-BASS INC.
00:DD:0E	Ungermann-             # UNGERMANN-BASS INC.
00:DD:0F	Ungermann-             # UNGERMANN-BASS INC.
00:E0:00	Fujitsu                # FUJITSU, LTD
00:E0:01	StrandLigh             # STRAND LIGHTING LIMITED
00:E0:02	Crossroads             # CROSSROADS SYSTEMS, INC.
00:E0:03	NokiaWirel             # NOKIA WIRELESS BUSINESS COMMUN
00:E0:04	Pmc-Sierra             # PMC-SIERRA, INC.
00:E0:05	Technical              # TECHNICAL CORP.
00:E0:06	SiliconInt             # SILICON INTEGRATED SYS. CORP.
00:E0:07	NetworkAlc             # NETWORK ALCHEMY LTD.
00:E0:08	AmazingCon             # AMAZING CONTROLS! INC.
00:E0:09	MarathonTe             # MARATHON TECHNOLOGIES CORP.
00:E0:0A	Diba                   # DIBA, INC.
00:E0:0B	RooftopCom             # ROOFTOP COMMUNICATIONS CORP.
00:E0:0C	Motorola
00:E0:0D	Radiant                # RADIANT SYSTEMS
00:E0:0E	AvalonImag             # AVALON IMAGING SYSTEMS, INC.
00:E0:0F	ShanghaiBa             # SHANGHAI BAUD DATA
00:E0:10	HessSb-Aut             # HESS SB-AUTOMATENBAU GmbH
00:E0:11	UnidenSanD             # UNIDEN SAN DIEGO R&D CENTER, INC.
00:E0:12	PlutoTechn             # PLUTO TECHNOLOGIES INTERNATIONAL INC.
00:E0:13	EasternEle             # EASTERN ELECTRONIC CO., LTD.
00:E0:14	Cisco                  # CISCO SYSTEMS, INC.
00:E0:15	Heiwa                  # HEIWA CORPORATION
00:E0:16	RapidCityC             # RAPID CITY COMMUNICATIONS
00:E0:17	Exxact                 # EXXACT GmbH
00:E0:18	AsustekCom             # ASUSTEK COMPUTER INC.
00:E0:19	IngGiordan             # ING. GIORDANO ELETTRONICA
00:E0:1A	Comtec                 # COMTEC SYSTEMS. CO., LTD.
00:E0:1B	SphereComm             # SPHERE COMMUNICATIONS, INC.
00:E0:1C	MobilityEl             # MOBILITY ELECTRONICSY
00:E0:1D	WebtvNetwo             # WebTV NETWORKS, INC.
00:E0:1E	Cisco                  # CISCO SYSTEMS, INC.
00:E0:1F	Avidia                 # AVIDIA Systems, Inc.
00:E0:20	TecnomenOy             # TECNOMEN OY
00:E0:21	Freegate               # FREEGATE CORP.
00:E0:22	AnalogDevi             # Analog Devices Inc.
00:E0:23	Telrad
00:E0:24	GadzooxNet             # GADZOOX NETWORKS
00:E0:25	Dit                    # dit CO., LTD.
00:E0:26	RedlakeMas             # Redlake MASD LLC
00:E0:27	Dux                    # DUX, INC.
00:E0:28	Aptix                  # APTIX CORPORATION
00:E0:29	StandardMi             # STANDARD MICROSYSTEMS CORP.
00:E0:2A	TandbergTe             # TANDBERG TELEVISION AS
00:E0:2B	ExtremeNet             # EXTREME NETWORKS
00:E0:2C	AstCompute             # AST COMPUTER
00:E0:2D	Innomedial             # InnoMediaLogic, Inc.
00:E0:2E	SpcElectro             # SPC ELECTRONICS CORPORATION
00:E0:2F	McnsHoldin             # MCNS HOLDINGS, L.P.
00:E0:30	MelitaInte             # MELITA INTERNATIONAL CORP.
00:E0:31	HagiwaraEl             # HAGIWARA ELECTRIC CO., LTD.
00:E0:32	MisysFinan             # MISYS FINANCIAL SYSTEMS, LTD.
00:E0:33	EEPD                   # E.E.P.D. GmbH
00:E0:34	Cisco                  # CISCO SYSTEMS, INC.
00:E0:35	Loughborou             # LOUGHBOROUGH SOUND IMAGES, PLC
00:E0:36	Pioneer                # PIONEER CORPORATION
00:E0:37	Century                # CENTURY CORPORATION
00:E0:38	Proxima                # PROXIMA CORPORATION
00:E0:39	Paradyne               # PARADYNE CORP.
00:E0:3A	Cabletron              # CABLETRON SYSTEMS, INC.
00:E0:3B	Prominet               # PROMINET CORPORATION
00:E0:3C	Advansys
00:E0:3D	FoconElect             # FOCON ELECTRONIC SYSTEMS A/S
00:E0:3E	Alfatech               # ALFATECH, INC.
00:E0:3F	Jaton                  # JATON CORPORATION
00:E0:40	Deskstatio             # DeskStation Technology, Inc.
00:E0:41	Cspi
00:E0:42	Pacom                  # Pacom Systems Ltd.
00:E0:43	Vitalcom
00:E0:44	Lsics                  # LSICS CORPORATION
00:E0:45	Touchwave              # TOUCHWAVE, INC.
00:E0:46	BentlyNeva             # BENTLY NEVADA CORP.
00:E0:47	Infocus                # INFOCUS SYSTEMS
00:E0:48	SdlCommuni             # SDL COMMUNICATIONS, INC.
00:E0:49	MicrowiEle             # MICROWI ELECTRONIC GmbH
00:E0:4A	EnhancedMe             # ENHANCED MESSAGING SYSTEMS, INC
00:E0:4B	JumpIndust             # JUMP INDUSTRIELLE COMPUTERTECHNIK GmbH
00:E0:4C	RealtekSem             # REALTEK SEMICONDUCTOR CORP.
00:E0:4D	InternetIn             # INTERNET INITIATIVE JAPAN, INC
00:E0:4E	SanyoDenki             # SANYO DENKI CO., LTD.
00:E0:4F	Cisco                  # CISCO SYSTEMS, INC.
00:E0:50	ExecutoneI             # EXECUTONE INFORMATION SYSTEMS, INC.
00:E0:51	Talx                   # TALX CORPORATION
00:E0:52	FoundryNet             # FOUNDRY NETWORKS, INC.
00:E0:53	CellportLa             # CELLPORT LABS, INC.
00:E0:54	KodaiHitec             # KODAI HITEC CO., LTD.
00:E0:55	Ingenieria             # INGENIERIA ELECTRONICA COMERCIAL INELCOM S.A.
00:E0:56	Holontech              # HOLONTECH CORPORATION
00:E0:57	HanMicrote             # HAN MICROTELECOM. CO., LTD.
00:E0:58	PhaseOneDe             # PHASE ONE DENMARK A/S
00:E0:59	Controlled             # CONTROLLED ENVIRONMENTS, LTD.
00:E0:5A	GaleaNetwo             # GALEA NETWORK SECURITY
00:E0:5B	WestEnd                # WEST END SYSTEMS CORP.
00:E0:5C	Matsushita             # MATSUSHITA KOTOBUKI ELECTRONICS INDUSTRIES, LTD.
00:E0:5D	Unitec                 # UNITEC CO., LTD.
00:E0:5E	JapanAviat             # JAPAN AVIATION ELECTRONICS INDUSTRY, LTD.
00:E0:5F	E-Net                  # e-Net, Inc.
00:E0:60	Sherwood
00:E0:61	EdgepointN             # EdgePoint Networks, Inc.
00:E0:62	HostEngine             # HOST ENGINEERING
00:E0:63	Cabletron-             # CABLETRON - YAGO SYSTEMS, INC.
00:E0:64	SamsungEle             # SAMSUNG ELECTRONICS
00:E0:65	OpticalAcc             # OPTICAL ACCESS INTERNATIONAL
00:E0:66	Promax                 # ProMax Systems, Inc.
00:E0:67	EacAutomat             # eac AUTOMATION-CONSULTING GmbH
00:E0:68	Merrimac               # MERRIMAC SYSTEMS INC.
00:E0:69	Jaycor
00:E0:6A	Kapsch                 # KAPSCH AG
00:E0:6B	W&GSpecial             # W&G SPECIAL PRODUCTS
00:E0:6C	AepInterna             # AEP Systems International Ltd
00:E0:6D	Compuware              # COMPUWARE CORPORATION
00:E0:6E	FarSPA                 # FAR SYSTEMS S.p.A.
00:E0:6F	TerayonCom             # Terayon Communications Systems
00:E0:70	DhTechnolo             # DH TECHNOLOGY
00:E0:71	EpisMicroc             # EPIS MICROCOMPUTER
00:E0:72	Lynk
00:E0:73	NationalAm             # NATIONAL AMUSEMENT NETWORK, INC.
00:E0:74	TiernanCom             # TIERNAN COMMUNICATIONS, INC.
00:E0:75	Verilink               # Verilink Corporation
00:E0:76	Developmen             # DEVELOPMENT CONCEPTS, INC.
00:E0:77	Webgear                # WEBGEAR, INC.
00:E0:78	BerkeleyNe             # BERKELEY NETWORKS
00:E0:79	ATNR                   # A.T.N.R.
00:E0:7A	Mikrodidak             # MIKRODIDAKT AB
00:E0:7B	BayNetwork             # BAY NETWORKS
00:E0:7C	Mettler-To             # METTLER-TOLEDO, INC.
00:E0:7D	Netronix               # NETRONIX, INC.
00:E0:7E	WaltDisney             # WALT DISNEY IMAGINEERING
00:E0:7F	Logististe             # LOGISTISTEM s.r.l.
00:E0:80	ControlRes             # CONTROL RESOURCES CORPORATION
00:E0:81	TyanComput             # TYAN COMPUTER CORP.
00:E0:82	Anerma
00:E0:83	JatoTechno             # JATO TECHNOLOGIES, INC.
00:E0:84	CompuliteR             # COMPULITE R&D
00:E0:85	GlobalMain             # GLOBAL MAINTECH, INC.
00:E0:86	CybexCompu             # CYBEX COMPUTER PRODUCTS
00:E0:87	Lecroy-Net             # LeCroy - Networking Productions Division
00:E0:88	Ltx                    # LTX CORPORATION
00:E0:89	IonNetwork             # ION Networks, Inc.
00:E0:8A	GecAvery               # GEC AVERY, LTD.
00:E0:8B	Qlogic                 # QLogic Corp.
00:E0:8C	Neoparadig             # NEOPARADIGM LABS, INC.
00:E0:8D	Pressure               # PRESSURE SYSTEMS, INC.
00:E0:8E	Utstarcom
00:E0:8F	Cisco                  # CISCO SYSTEMS, INC.
00:E0:90	BeckmanLab             # BECKMAN LAB. AUTOMATION DIV.
00:E0:91	LgElectron             # LG ELECTRONICS, INC.
00:E0:92	Admtek                 # ADMTEK INCORPORATED
00:E0:93	AckfinNetw             # ACKFIN NETWORKS
00:E0:94	OsaiSrl                # OSAI SRL
00:E0:95	Advanced-V             # ADVANCED-VISION TECHNOLGIES CORP.
00:E0:96	Shimadzu               # SHIMADZU CORPORATION
00:E0:97	CarrierAcc             # CARRIER ACCESS CORPORATION
00:E0:98	Trend
00:E0:99	Samson                 # SAMSON AG
00:E0:9A	PositronIn             # POSITRON INDUSTRIES, INC.
00:E0:9B	EngageNetw             # ENGAGE NETWORKS, INC.
00:E0:9C	Mii
00:E0:9D	Sarnoff                # SARNOFF CORPORATION
00:E0:9E	Quantum                # QUANTUM CORPORATION
00:E0:9F	PixelVisio             # PIXEL VISION
00:E0:A0	Wiltron                # WILTRON CO.
00:E0:A1	HimaPaulHi             # HIMA PAUL HILDEBRANDT GmbH Co. KG
00:E0:A2	Microslate             # MICROSLATE INC.
00:E0:A3	Cisco                  # CISCO SYSTEMS, INC.
00:E0:A4	EsaoteSPA              # ESAOTE S.p.A.
00:E0:A5	ComcoreSem             # ComCore Semiconductor, Inc.
00:E0:A6	TelogyNetw             # TELOGY NETWORKS, INC.
00:E0:A7	IpcInforma             # IPC INFORMATION SYSTEMS, INC.
00:E0:A8	Sat                    # SAT GmbH & Co.
00:E0:A9	FunaiElect             # FUNAI ELECTRIC CO., LTD.
00:E0:AA	Electroson             # ELECTROSONIC LTD.
00:E0:AB	DimatSA                # DIMAT S.A.
00:E0:AC	Midsco                 # MIDSCO, INC.
00:E0:AD	EesTechnol             # EES TECHNOLOGY, LTD.
00:E0:AE	Xaqti                  # XAQTI CORPORATION
00:E0:AF	GeneralDyn             # GENERAL DYNAMICS INFORMATION SYSTEMS
00:E0:B0	Cisco                  # CISCO SYSTEMS, INC.
00:E0:B1	AlcatelNor             # Alcatel North America ESD
00:E0:B2	TelmaxComm             # TELMAX COMMUNICATIONS CORP.
00:E0:B3	Etherwan               # EtherWAN Systems, Inc.
00:E0:B4	TechnoScop             # TECHNO SCOPE CO., LTD.
00:E0:B5	ArdentComm             # ARDENT COMMUNICATIONS CORP.
00:E0:B6	EntradaNet             # Entrada Networks
00:E0:B7	PiGroup                # PI GROUP, LTD.
00:E0:B8	Gateway200             # GATEWAY 2000
00:E0:B9	Byas                   # BYAS SYSTEMS
00:E0:BA	BerghofAut             # BERGHOF AUTOMATIONSTECHNIK GmbH
00:E0:BB	Nbx                    # NBX CORPORATION
00:E0:BC	SymonCommu             # SYMON COMMUNICATIONS, INC.
00:E0:BD	Interface              # INTERFACE SYSTEMS, INC.
00:E0:BE	GenrocoInt             # GENROCO INTERNATIONAL, INC.
00:E0:BF	TorrentNet             # TORRENT NETWORKING TECHNOLOGIES CORP.
00:E0:C0	SeiwaElect             # SEIWA ELECTRIC MFG. CO., LTD.
00:E0:C1	MemorexTel             # MEMOREX TELEX JAPAN, LTD.
00:E0:C2	NecsySPA               # NECSY S.p.A.
00:E0:C3	SakaiSyste             # SAKAI SYSTEM DEVELOPMENT CORP.
00:E0:C4	HornerElec             # HORNER ELECTRIC, INC.
00:E0:C5	BcomElectr             # BCOM ELECTRONICS INC.
00:E0:C6	Link2itLLC             # LINK2IT, L.L.C.
00:E0:C7	EurotechSr             # EUROTECH SRL
00:E0:C8	VirtualAcc             # VIRTUAL ACCESS, LTD.
00:E0:C9	Automatedl             # AutomatedLogic Corporation
00:E0:CA	BestDataPr             # BEST DATA PRODUCTS
00:E0:CB	Reson                  # RESON, INC.
00:E0:CC	Hero                   # HERO SYSTEMS, LTD.
00:E0:CD	Sensis                 # SENSIS CORPORATION
00:E0:CE	Arn
00:E0:CF	Integrated             # INTEGRATED DEVICE TECHNOLOGY, INC.
00:E0:D0	Netspeed               # NETSPEED, INC.
00:E0:D1	Telsis                 # TELSIS LIMITED
00:E0:D2	VersanetCo             # VERSANET COMMUNICATIONS, INC.
00:E0:D3	Datentechn             # DATENTECHNIK GmbH
00:E0:D4	ExcellentC             # EXCELLENT COMPUTER
00:E0:D5	ArcxelTech             # ARCXEL TECHNOLOGIES, INC.
00:E0:D6	ComputerCo             # COMPUTER & COMMUNICATION RESEARCH LAB.
00:E0:D7	SunshineEl             # SUNSHINE ELECTRONICS, INC.
00:E0:D8	LanbitComp             # LANBit Computer, Inc.
00:E0:D9	Tazmo                  # TAZMO CO., LTD.
00:E0:DA	AlcatelNor             # Alcatel North America ESD
00:E0:DB	ViavideoCo             # ViaVideo Communications, Inc.
00:E0:DC	Nexware                # NEXWARE CORP.
00:E0:DD	ZenithElec             # ZENITH ELECTRONICS CORPORATION
00:E0:DE	DataxNv                # DATAX NV
00:E0:DF	KeKommunik             # KE KOMMUNIKATIONS-ELECTRONIK
00:E0:E0	SiElectron             # SI ELECTRONICS, LTD.
00:E0:E1	G2Networks             # G2 NETWORKS, INC.
00:E0:E2	Innova                 # INNOVA CORP.
00:E0:E3	Sk-Elektro             # SK-ELEKTRONIK GmbH
00:E0:E4	FanucRobot             # FANUC ROBOTICS NORTH AMERICA, Inc.
00:E0:E5	CincoNetwo             # CINCO NETWORKS, INC.
00:E0:E6	IncaaDatac             # INCAA DATACOM B.V.
00:E0:E7	RaytheonE-             # RAYTHEON E-SYSTEMS, INC.
00:E0:E8	Gretacoder             # GRETACODER Data Systems AG
00:E0:E9	DataLabs               # DATA LABS, INC.
00:E0:EA	InnovatCom             # INNOVAT COMMUNICATIONS, INC.
00:E0:EB	Digicom                # DIGICOM SYSTEMS, INCORPORATED
00:E0:EC	Celestica              # CELESTICA INC.
00:E0:ED	Silicom                # SILICOM, LTD.
00:E0:EE	MarelHf                # MAREL HF
00:E0:EF	Dionex
00:E0:F0	AblerTechn             # ABLER TECHNOLOGY, INC.
00:E0:F1	That                   # THAT CORPORATION
00:E0:F2	ArlottoCom             # ARLOTTO COMNET, INC.
00:E0:F3	WebsprintC             # WebSprint Communications, Inc.
00:E0:F4	InsideTech             # INSIDE Technology A/S
00:E0:F5	Teles                  # TELES AG
00:E0:F6	DecisionEu             # DECISION EUROPE
00:E0:F7	Cisco                  # CISCO SYSTEMS, INC.
00:E0:F8	DicnaContr             # DICNA CONTROL AB
00:E0:F9	Cisco                  # CISCO SYSTEMS, INC.
00:E0:FA	TrlTechnol             # TRL TECHNOLOGY, LTD.
00:E0:FB	Leightroni             # LEIGHTRONIX, INC.
00:E0:FC	HuaweiTech             # HUAWEI TECHNOLOGIES CO., LTD.
00:E0:FD	A-TrendTec             # A-TREND TECHNOLOGY CO., LTD.
00:E0:FE	Cisco                  # CISCO SYSTEMS, INC.
00:E0:FF	SecurityDy             # SECURITY DYNAMICS TECHNOLOGIES, Inc.
00:E6:D3	NixdorfCom             # NIXDORF COMPUTER CORP.
02:04:06	BbnInterna             # BBN				internal usage (not registered)
02:07:01	Racal-Data             # RACAL-DATACOM
02:1C:7C	Perq                   # PERQ SYSTEMS CORPORATION
02:20:48	Marconi		# At least some 2810 send with locally assigned flag set
02:60:60	3com
02:60:86	LogicRepla             # LOGIC REPLACEMENT TECH. LTD.
02:60:8C	3com                   # 3COM CORPORATION
02:70:01	Racal-Data             # RACAL-DATACOM
02:70:B0	M/A-ComCom             # M/A-COM INC. COMPANIES
02:70:B3	DataRecall             # DATA RECALL LTD
02:9D:8E	CardiacRec             # CARDIAC RECORDERS INC.
02:A0:C9	Intel
02:AA:3C	OlivettiTe             # OLIVETTI TELECOMM SPA (OLTECO)
02:BB:01	Octothorpe             # OCTOTHORPE CORP.
02:C0:8C	3com                   # 3COM CORPORATION
02:CF:1C	Communicat             # COMMUNICATION MACHINERY CORP.
02:CF:1F	CMC
02:E0:3B	ProminetCo             # Prominet Corporation		Gigabit Ethernet Switch
02:E6:D3	NixdorfCom             # NIXDORF COMPUTER CORPORATION
04:0A:E0	XmitComput             # XMIT AG COMPUTER NETWORKS
04:88:45	BayNetwork             # Bay Networks			token ring line card
04:E0:C4	Triumph-Ad             # TRIUMPH-ADLER AG
08:00:01	Computervi             # COMPUTERVISION CORPORATION
08:00:02	3Com
08:00:03	ACC
08:00:04	Cromemco               # CROMEMCO INCORPORATED
08:00:05	Symbolics              # SYMBOLICS INC.
08:00:06	Siemens                # SIEMENS AG
08:00:07	AppleCompu             # APPLE COMPUTER INC.
08:00:08	BBN
08:00:09	HP
08:00:0A	Nestar                 # NESTAR SYSTEMS INCORPORATED
08:00:0B	Unisys                 # UNISYS CORPORATION
08:00:0C	MiklynDeve             # MIKLYN DEVELOPMENT CO.
08:00:0D	Internatio             # INTERNATIONAL COMPUTERS LTD.
08:00:0E	Ncr                    # NCR CORPORATION
08:00:0F	Mitel                  # MITEL CORPORATION
08:00:10	At&T[Misre             # AT&T [misrepresentation of 800010?]
08:00:11	Tektronix              # TEKTRONIX INC.
08:00:12	BellAtlant             # BELL ATLANTIC INTEGRATED SYST.
08:00:13	Exxon
08:00:14	Excelan
08:00:15	StcBusines             # STC BUSINESS SYSTEMS
08:00:16	BarristerI             # BARRISTER INFO SYS CORP
08:00:17	NationalSe             # NATIONAL SEMICONDUCTOR
08:00:18	PirelliFoc             # PIRELLI FOCOM NETWORKS
08:00:19	GeneralEle             # GENERAL ELECTRIC CORPORATION
08:00:1A	DataGenl	# Data General
08:00:1B	DataGenera             # DATA GENERAL
08:00:1C	Kdd-Kokusa             # KDD-KOKUSAI DEBNSIN DENWA CO.
08:00:1D	AbleCommun             # ABLE COMMUNICATIONS INC.
08:00:1E	ApolloComp             # APOLLO COMPUTER INC.
08:00:1F	Sharp                  # SHARP CORPORATION
08:00:20	SunMicrosy             # SUN MICROSYSTEMS INC.
08:00:21	3m                     # 3M COMPANY
08:00:22	Nbi                    # NBI INC.
08:00:23	PanasonicC             # Panasonic Communications Co., Ltd.
08:00:24	10netCommu             # 10NET COMMUNICATIONS/DCA
08:00:25	ControlDat             # CONTROL DATA
08:00:26	NorskDataA             # NORSK DATA A.S.
08:00:27	CadmusComp             # CADMUS COMPUTER SYSTEMS
08:00:28	TexasInstr             # Texas Instruments
08:00:29	Megatek                # MEGATEK CORPORATION
08:00:2A	MosaicTech             # MOSAIC TECHNOLOGIES INC.
08:00:2B	DigitalEqu             # DIGITAL EQUIPMENT CORPORATION
08:00:2C	BrittonLee             # BRITTON LEE INC.
08:00:2D	Lan-Tec                # LAN-TEC INC.
08:00:2E	MetaphorCo             # METAPHOR COMPUTER SYSTEMS
08:00:2F	PrimeCompu             # PRIME COMPUTER INC.
08:00:30	NetworkRes             # NETWORK RESEARCH CORPORATION
08:00:31	LittleMach             # LITTLE MACHINES INC.
08:00:32	Tigan                  # TIGAN INCORPORATED
08:00:33	BauschLomb             # BAUSCH & LOMB
08:00:34	Filenet                # FILENET CORPORATION
08:00:35	Microfive              # MICROFIVE CORPORATION
08:00:36	Intergraph             # INTERGRAPH CORPORATION
08:00:37	Fuji-Xerox             # FUJI-XEROX CO. LTD.
08:00:38	Bull
08:00:39	Spider                 # SPIDER SYSTEMS LIMITED
08:00:3A	Orcatech               # ORCATECH INC.
08:00:3B	Torus                  # TORUS SYSTEMS LIMITED
08:00:3C	Schlumberg             # SCHLUMBERGER WELL SERVICES
08:00:3D	CadnetixCo             # CADNETIX CORPORATIONS
08:00:3E	Motorola
08:00:3F	FredKoscha             # FRED KOSCHARA ENTERPRISES
08:00:40	FerrantiCo             # FERRANTI COMPUTER SYS. LIMITED
08:00:41	Racal-Milg             # RACAL-MILGO INFORMATION SYS..
08:00:42	JapanMacni             # JAPAN MACNICS CORP.
08:00:43	PixelCompu             # PIXEL COMPUTER INC.
08:00:44	David                  # DAVID SYSTEMS INC.
08:00:45	Concurrent             # CONCURRENT COMPUTER CORP.
08:00:46	Sony                   # SONY CORPORATION LTD.
08:00:47	SequentCom             # SEQUENT COMPUTER SYSTEMS INC.
08:00:48	EurothermG             # EUROTHERM GAUGING SYSTEMS
08:00:49	Univation
08:00:4A	Banyan                 # BANYAN SYSTEMS INC.
08:00:4B	PlanningRe             # PLANNING RESEARCH CORP.
08:00:4C	HydraCompu             # HYDRA COMPUTER SYSTEMS INC.
08:00:4D	Corvus                 # CORVUS SYSTEMS INC.
08:00:4E	3comEurope             # 3COM EUROPE LTD.
08:00:4F	Cygnet                 # CYGNET SYSTEMS
08:00:50	Daisy                  # DAISY SYSTEMS CORP.
08:00:51	Experdata
08:00:52	Insystec
08:00:53	MiddleEast             # MIDDLE EAST TECH. UNIVERSITY
08:00:55	StanfordTe             # STANFORD TELECOMM. INC.
08:00:56	StanfordLi             # STANFORD LINEAR ACCEL. CENTER
08:00:57	EvansSuthe             # EVANS & SUTHERLAND
08:00:58	Concepts               # SYSTEMS CONCEPTS
08:00:59	Mycron                 # A/S MYCRON
08:00:5A	Ibm                    # IBM CORPORATION
08:00:5B	VtaTechnol             # VTA TECHNOLOGIES INC.
08:00:5C	FourPhase              # FOUR PHASE SYSTEMS
08:00:5D	Gould                  # GOULD INC.
08:00:5E	Counterpoi             # COUNTERPOINT COMPUTER INC.
08:00:5F	SaberTechn             # SABER TECHNOLOGY CORP.
08:00:60	Industrial             # INDUSTRIAL NETWORKING INC.
08:00:61	Jarogate               # JAROGATE LTD.
08:00:62	GeneralDyn             # GENERAL DYNAMICS
08:00:63	Plessey
08:00:64	Autophon               # AUTOPHON AG
08:00:65	Genrad                 # GENRAD INC.
08:00:66	Agfa                   # AGFA CORPORATION
08:00:67	Comdesign
08:00:68	RidgeCompu             # RIDGE COMPUTERS
08:00:69	SGI
08:00:6A	AttBellLab             # ATT BELL LABORATORIES
08:00:6B	AccelTechn             # ACCEL TECHNOLOGIES INC.
08:00:6C	SuntekTech             # SUNTEK TECHNOLOGY INT'L
08:00:6D	Whitechape             # WHITECHAPEL COMPUTER WORKS
08:00:6E	Masscomp
08:00:6F	PhilipsApe             # PHILIPS APELDOORN B.V.
08:00:70	Mitsubishi             # MITSUBISHI ELECTRIC CORP.
08:00:71	MatraDsie              # MATRA (DSIE)
08:00:72	XeroxUnivG             # XEROX CORP UNIV GRANT PROGRAM
08:00:73	Tecmar                 # TECMAR INC.
08:00:74	CasioCompu             # CASIO COMPUTER CO. LTD.
08:00:75	DanskDataE             # DANSK DATA ELECTRONIK
08:00:76	PcLanTechn             # PC LAN TECHNOLOGIES
08:00:77	TslCommuni             # TSL COMMUNICATIONS LTD.
08:00:78	Accell                 # ACCELL CORPORATION
08:00:79	SGI
08:00:7A	Indata
08:00:7B	SanyoElect             # SANYO ELECTRIC CO. LTD.
08:00:7C	VitalinkCo             # VITALINK COMMUNICATIONS CORP.
08:00:7E	Amalgamate             # AMALGAMATED WIRELESS(AUS) LTD
08:00:7F	Carnegie-M             # CARNEGIE-MELLON UNIVERSITY
08:00:80	AesData                # AES DATA INC.
08:00:81	Astech                 # ,ASTECH INC.
08:00:82	VeritasSof             # VERITAS SOFTWARE
08:00:83	SeikoInstr             # Seiko Instruments Inc.
08:00:84	TomenElect             # TOMEN ELECTRONICS CORP.
08:00:85	Elxsi
08:00:86	KonicaMino             # KONICA MINOLTA HOLDINGS, INC.
08:00:87	Xyplex
08:00:88	Mcdata                 # MCDATA CORPORATION
08:00:89	Kinetics
08:00:8A	Performanc             # PERFORMANCE TECHNOLOGY
08:00:8B	PyramidTec             # PYRAMID TECHNOLOGY CORP.
08:00:8C	NetworkRes             # NETWORK RESEARCH CORPORATION
08:00:8D	Xyvision               # XYVISION INC.
08:00:8E	TandemComp             # TANDEM COMPUTERS
08:00:8F	Chipcom                # CHIPCOM CORPORATION
08:00:90	Retix
08:14:43	UnibrainSA             # UNIBRAIN S.A.
08:BB:CC	Ak-NordEdv             # AK-NORD EDV VERTRIEBSGES. mbH
09:00:6A	AT&T
10:00:00	Private
10:00:5A	Ibm                    # IBM CORPORATION
10:00:90	HP
10:00:D4	DEC
10:00:E0	AppleA/UxM             # Apple A/UX			(modified addresses for licensing)
10:00:E8	NationalSe             # NATIONAL SEMICONDUCTOR
11:00:AA	Private
2E:2E:2E	LaaLocally             # LAA (Locally Administered Address) for Meditech Systems
3C:00:00	3Com
40:00:03	NetWare?               # Net Ware (?)
44:45:53	Microsoft
44:46:49	DfiDiamond             # DFI (Diamond Flower Industries)
47:54:43	GtcNotRegi             # GTC (Not registered!)		(This number is a multicast!)
48:44:53	Hds???                 # HDS ???
48:4C:00	NetworkSol             # Network Solutions
48:54:E8	Winbond?
4C:42:4C	Informatio             # Information Modes software modified addresses (not registered?)
52:54:00	RealtekUpt             # Realtek (UpTech? also reported)
52:54:4C	Novell2000             # Novell 2000
52:54:AB	RealtekARe             # REALTEK (a Realtek 8029 based PCI Card)
56:58:57	AculabPlcA             # Aculab plc			audio bridges
80:00:10	AttBellLab             # ATT BELL LABORATORIES
80:AD:00	CnetTechno             # CNET Technology Inc. (Probably an error, see instead 0080AD)
A0:6A:00	Verilink               # Verilink Corporation
AA:00:00	DigitalEqu             # DIGITAL EQUIPMENT CORPORATION
AA:00:01	DigitalEqu             # DIGITAL EQUIPMENT CORPORATION
AA:00:02	DigitalEqu             # DIGITAL EQUIPMENT CORPORATION
AA:00:03	DigitalEqu             # DIGITAL EQUIPMENT CORPORATION
AA:00:04	DigitalEqu             # DIGITAL EQUIPMENT CORPORATION
AC:DE:48	Private
C0:00:00	WesternDig             # Western Digital (may be reversed 00 00 C0?)
E2:0C:0F	KingstonTe             # Kingston Technologies
EC:10:00	EnanceSour             # Enance Source Co., Ltd.	PC clones(?)
00-00-0C-07-AC/40	All-HSRP-routers
00-00-5E-00-01/40	IETF-VRRP-virtual-router-VRID
00-BF-00-00-00-00/16	MS-NLB-VirtServer
00-E0-2B-00-00-00	Extreme-EDP
00-E0-2B-00-00-01	Extreme-EAPS-Source
00-E0-2B-00-00-02	Extreme-ESRP-Client
00-E0-2B-00-00-04	Extreme-EAPSv1
00-E0-2B-00-00-08	Extreme-ESRP-Master
01-00-0C-00-00/40	ISL-Frame
01-00-0C-CC-CC-CC	CDP/VTP/DTP/PAgP/UDLD
01-00-0C-CC-CC-CD	PVST+
01-00-0C-CD-CD-CD	STP-UplinkFast
01-00-0C-CD-CD-CE	VLAN-bridge
01-00-0C-DD-DD-DD	CGMP
01-00-10-00-00-20	Hughes-Lan-Systems-Terminal-Server-S/W-download
01-00-10-FF-FF-20	Hughes-Lan-Systems-Terminal-Server-S/W-request
01-00-1D-00-00-00	Cabletron-PC-OV-PC-discover-(on-demand)
01-00-1D-00-00-05	Cabletron-PVST-BPDU
01-00-1D-00-00-06	Cabletron-QCSTP-BPDU
01-00-1D-42-00-00	Cabletron-PC-OV-Bridge-discover-(on-demand)
01-00-1D-52-00-00	Cabletron-PC-OV-MMAC-discover-(on-demand)
01-00-3C		Auspex-Systems-(Serverguard)
01-00-81-00-00-00	Synoptics-Network-Management
01-00-81-00-00-02	Synoptics-Network-Management
01-00-81-00-01-00	Bay-Networks-(Synoptics)-autodiscovery
01-00-81-00-01-01	Bay-Networks-(Synoptics)-autodiscovery
01-20-25/25		Control-Technology-Inc's-Industrial-Ctrl-Proto.
01-80-24-00-00-00	Kalpana-Etherswitch-every-60-seconds
01-80-C2-00-00-00/44	Spanning-tree-(for-bridges)
01-80-C2-00-00-02	Slow-Protocols
01-80-C2-00-00-0E	LLDP_Multicast
01-80-C2-00-00-10	Bridge-Management
01-80-C2-00-00-11	Load-Server
01-80-C2-00-00-12	Loadable-Device
01-80-C2-00-00-14	ISIS-all-level-1-IS's
01-80-C2-00-00-15	ISIS-all-level-2-IS's
01-80-C2-00-01-00	FDDI-RMT-Directed-Beacon
01-80-C2-00-01-10	FDDI-status-report-frame
01-DD-00-FF-FF-FF	Ungermann-Bass-boot-me-requests
01-DD-01-00-00-00	Ungermann-Bass-Spanning-Tree
01-E0-52-CC-CC-CC	Foundry-DP
# Microsoft Network Load Balancing (NLB)
# Actually, 02-01-virtualip to 02-20-virtualip will be used from server to rest-of-world
# 02-bf-virtualip will be used from rest-of-world to server
02-BF-00-00-00-00/16	MS-NLB-VirtServer
02-01-00-00-00-00/16	MS-NLB-PhysServer-01
02-02-00-00-00-00/16	MS-NLB-PhysServer-02
02-03-00-00-00-00/16	MS-NLB-PhysServer-03
02-04-00-00-00-00/16	MS-NLB-PhysServer-04
02-05-00-00-00-00/16	MS-NLB-PhysServer-05
02-06-00-00-00-00/16	MS-NLB-PhysServer-06
02-07-00-00-00-00/16	MS-NLB-PhysServer-07
02-08-00-00-00-00/16	MS-NLB-PhysServer-08
02-09-00-00-00-00/16	MS-NLB-PhysServer-09
02-0a-00-00-00-00/16	MS-NLB-PhysServer-10
02-0b-00-00-00-00/16	MS-NLB-PhysServer-11
02-0c-00-00-00-00/16	MS-NLB-PhysServer-12
02-0d-00-00-00-00/16	MS-NLB-PhysServer-13
02-0e-00-00-00-00/16	MS-NLB-PhysServer-14
02-0f-00-00-00-00/16	MS-NLB-PhysServer-15
02-10-00-00-00-00/16	MS-NLB-PhysServer-16
02-11-00-00-00-00/16	MS-NLB-PhysServer-17
02-12-00-00-00-00/16	MS-NLB-PhysServer-18
02-13-00-00-00-00/16	MS-NLB-PhysServer-19
02-14-00-00-00-00/16	MS-NLB-PhysServer-20
02-15-00-00-00-00/16	MS-NLB-PhysServer-21
02-16-00-00-00-00/16	MS-NLB-PhysServer-22
02-17-00-00-00-00/16	MS-NLB-PhysServer-23
02-18-00-00-00-00/16	MS-NLB-PhysServer-24
02-19-00-00-00-00/16	MS-NLB-PhysServer-25
02-1a-00-00-00-00/16	MS-NLB-PhysServer-26
02-1b-00-00-00-00/16	MS-NLB-PhysServer-27
02-1c-00-00-00-00/16	MS-NLB-PhysServer-28
02-1d-00-00-00-00/16	MS-NLB-PhysServer-29
02-1e-00-00-00-00/16	MS-NLB-PhysServer-30
02-1f-00-00-00-00/16	MS-NLB-PhysServer-31
02-20-00-00-00-00/16	MS-NLB-PhysServer-32

#       [ The following block of addresses (03-...) are used by various ]
#       [ standards.  Some (marked [TR?]) are suspected of only being   ]
#       [ used on Token Ring for group addresses of Token Ring specific ]
#       [ functions, reference ISO 8802-5:1995 aka. IEEE 802.5:1995 for ]
#       [ some info.  These in the Ethernet order for this list.  On    ]
#       [ Token Ring they appear reversed.  They should never appear on ]
#       [ Ethernet.  Others, not so marked, are normal reports (may be  ]
#       [ seen on either).
03-00-00-00-00-01	NETBIOS-# [TR?]
03-00-00-00-00-02	Locate-Directory-Server # [TR?]
03-00-00-00-00-04	Synchronous-Bandwidth-Manager-# [TR?]
03-00-00-00-00-08	Configuration-Report-Server-# [TR?]
03-00-00-00-00-10	Ring-Error-Monitor-# [TR?]
03-00-00-00-00-10	(OS/2-1.3-EE+Communications-Manager)
03-00-00-00-00-20	Network-Server-Heartbeat-# [TR?]
03-00-00-00-00-40	(OS/2-1.3-EE+Communications-Manager)
03-00-00-00-00-80	Active-Monitor # [TR?]
03-00-00-00-01-00	OSI-All-IS-Token-Ring-Multicast
03-00-00-00-02-00	OSI-All-ES-Token-Ring-Multicast
03-00-00-00-04-00	LAN-Manager # [TR?]
03-00-00-00-08-00	Ring-Wiring-Concentrator # [TR?]
03-00-00-00-10-00	LAN-Gateway # [TR?]
03-00-00-00-20-00	Ring-Authorization-Server # [TR?]
03-00-00-00-40-00	IMPL-Server # [TR?]
03-00-00-00-80-00	Bridge # [TR?]
03-00-00-20-00-00	IP-Token-Ring-Multicast # (RFC1469)
03-00-00-80-00-00	Discovery-Client
03-00-C7-00-00-EE	HP # (Compaq) ProLiant NIC teaming
03-00-FF-FF-FF-FF	All-Stations-Address
03-BF-00-00-00-00/16	MS-NLB-VirtServer-Multicast
09-00-07-00-00-00/40	AppleTalk-Zone-multicast-addresses # only goes through 09-00-07-00-00-FC?
09-00-07-FF-FF-FF	AppleTalk-broadcast-address
09-00-09-00-00-01	HP-Probe
09-00-09-00-00-04	HP-DTC
09-00-0D-00-00-00/24	ICL-Oslan-Multicast
09-00-0D-02-00-00	ICL-Oslan-Service-discover-only-on-boot
09-00-0D-02-0A-38	ICL-Oslan-Service-discover-only-on-boot
09-00-0D-02-0A-39	ICL-Oslan-Service-discover-only-on-boot
09-00-0D-02-0A-3C	ICL-Oslan-Service-discover-only-on-boot
09-00-0D-02-FF-FF	ICL-Oslan-Service-discover-only-on-boot
09-00-0D-09-00-00	ICL-Oslan-Service-discover-as-required
09-00-1E-00-00-00	Apollo-DOMAIN
09-00-2B-00-00-00	DEC-MUMPS?
09-00-2B-00-00-01	DEC-DSM/DDP
09-00-2B-00-00-02	DEC-VAXELN?
09-00-2B-00-00-03	DEC-Lanbridge-Traffic-Monitor-(LTM)
09-00-2B-00-00-04	DEC-MAP-(or-OSI?)-End-System-Hello?
09-00-2B-00-00-05	DEC-MAP-(or-OSI?)-Intermediate-System-Hello?
09-00-2B-00-00-06	DEC-CSMA/CD-Encryption?
09-00-2B-00-00-07	DEC-NetBios-Emulator?
09-00-2B-00-00-0F	DEC-Local-Area-Transport-(LAT)
09-00-2B-00-00-10/44	DEC-Experimental
09-00-2B-01-00-00	DEC-LanBridge-Copy-packets-(All-bridges)
09-00-2B-01-00-01	DEC-LanBridge-Hello-packets-(All-local-bridges)
09-00-2B-02-00-00	DEC-DNA-Level-2-Routing-Layer-routers?
09-00-2B-02-01-00	DEC-DNA-Naming-Service-Advertisement?
09-00-2B-02-01-01	DEC-DNA-Naming-Service-Solicitation?
09-00-2B-02-01-09	DEC-Availability-Manager-for-Distributed-Systems-DECamds
09-00-2B-02-01-02	DEC-Distributed-Time-Service
09-00-2B-03-00-00/32	DEC-default-filtering-by-bridges?
09-00-2B-04-00-00	DEC-Local-Area-System-Transport-(LAST)?
09-00-2B-23-00-00	DEC-Argonaut-Console?
09-00-4C-00-00-00	BICC-802.1-management
09-00-4C-00-00-02	BICC-802.1-management
09-00-4C-00-00-06	BICC-Local-bridge-STA-802.1(D)-Rev6
09-00-4C-00-00-0C	BICC-Remote-bridge-STA-802.1(D)-Rev8
09-00-4C-00-00-0F	BICC-Remote-bridge-ADAPTIVE-ROUTING
09-00-56-FF-00-00/32	Stanford-V-Kernel,-version-6.0
09-00-6A-00-01-00	TOP-NetBIOS.
09-00-77-00-00-00	Retix-Bridge-Local-Management-System
09-00-77-00-00-01	Retix-spanning-tree-bridges
09-00-77-00-00-02	Retix-Bridge-Adaptive-routing
09-00-7C-01-00-01	Vitalink-DLS-Multicast
09-00-7C-01-00-03	Vitalink-DLS-Inlink
09-00-7C-01-00-04	Vitalink-DLS-and-non-DLS-Multicast
09-00-7C-02-00-05	Vitalink-diagnostics
09-00-7C-05-00-01	Vitalink-gateway?
09-00-7C-05-00-02	Vitalink-Network-Validation-Message
09-00-87-80-FF-FF	Xyplex-Terminal-Servers
09-00-87-90-FF-FF	Xyplex-Terminal-Servers
0C-00-0C-00-00/40	ISL-Frame
0D-1E-15-BA-DD-06	HP
20-52-45-43-56-00/40	Receive
20-53-45-4E-44-00/40	Send
33-33-00-00-00-00/16	IPv6-Neighbor-Discovery
AA-00-03-00-00-00/32	DEC-UNA	
AA-00-03-01-00-00/32	DEC-PROM-AA
AA-00-03-03-00-00/32	DEC-NI20
AB-00-00-01-00-00	DEC-MOP-Dump/Load-Assistance
AB-00-00-02-00-00	DEC-MOP-Remote-Console
AB-00-00-03-00-00	DECNET-Phase-IV-end-node-Hello-packets
AB-00-00-04-00-00	DECNET-Phase-IV-Router-Hello-packets
AB-00-03-00-00-00	DEC-Local-Area-Transport-(LAT)-old
AB-00-04-01-00-00/32	DEC-Local-Area-VAX-Cluster-groups-SCA
CF-00-00-00-00-00	Ethernet-Configuration-Test-protocol-(Loopback)
FF-FF-00-60-00-04	Lantastic
FF-FF-00-40-00-01	Lantastic
FF-FF-01-E0-00-04	Lantastic
FF-FF-FF-FF-FF-FF	Broadcast
