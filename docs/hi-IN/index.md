---
title: प्रदर्शित करता है
description: मॉनिटर और लेआउट कॉन्फ़िगर करें।
---

`argvus-display` प्रदान करता है और सहेजे गए लेआउट को Hyprland के साथ एकीकृत करता है। स्थिति का निरीक्षण करें:

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```

। सहायक /docs/reference/configuration-files/ और  --set <monitor> <key> <value>  `argvus displayctl`  `--set <monitor> <key> <value>` `--apply-nwg` का भी समर्थन करता है। जेनरेट किए गए मॉनिटर ओवरराइड ARGVUS कॉन्फ़िगरेशन स्थिति का हिस्सा हैं; देखें [कॉन्फ़िगरेशन फ़ाइलें](/docs/reference/configuration-files/)।

कंट्रोल सेंटर में, **डिस्प्ले** खोलें या किसी मॉनीटर को खोजें। उपलब्ध सेटिंग्स क्षमता पर निर्भर होती हैं और इसमें रिज़ॉल्यूशन, रिफ्रेश रेट, स्केल, स्थिति, ओरिएंटेशन, प्राथमिक डिस्प्ले, VRR और HDR शामिल हो सकते हैं। किसी सेटिंग को केवल इसलिए समर्थित नहीं दिखाया जाता क्योंकि मॉनीटर मॉडल एक सामान्य सूची में मौजूद है; सक्रिय कंपोजिटर और मॉनीटर बैकएंड को इसे रिपोर्ट करना आवश्यक है।

डिस्प्ले लेआउट लागू करने से चल रहे Hyprland मॉनिटर कॉन्फ़िगरेशन में बदलाव आता है और बाद के सत्रों के लिए समर्थित लेआउट स्टेट सेव हो जाता है। जब उपलब्ध हो, पेज के लागू/वापस करें फ्लो का उपयोग करें। यदि कोई मॉनिटर अनुपयोगी हो जाता है, तो डिस्प्ले पेज पर लौटें या उत्पन्न फ़ाइलों को संपादित करने के बजाय `argvus displayctl --apply` में सेव किए गए स्टेट का उपयोग करें।

## कमांड-लाइन डिस्प्ले प्रबंधन

ग्राफिकल इंटरफेस के बिना डिस्प्ले सेटिंग्स को क्वेरी और बदलने के लिए `argvus displayctl` का उपयोग करें:

```sh
# Show monitor status and names
argvus displayctl --status

# List available modes for a monitor
argvus displayctl --list-modes <monitor>

# Set a specific property
argvus displayctl --set <monitor> scale 1.25
argvus displayctl --set <monitor> dpi 120
argvus displayctl --set <monitor> power off
argvus displayctl --set <monitor> power on

# Apply saved layout
argvus displayctl --apply

# Open the graphical display settings
argvus displayctl --settings
```

मॉनिटर नाम  eDP-1  DP-2  HDMI-1  `--status`  `HDMI-1`  `DP-2`  `eDP-1` `--settings` द्वारा दिखाए जाते हैं (आमतौर पर लैपटॉप के लिए --settings, --settings, --settings)। GUI के साथ बदलाव करने के लिए --settings का उपयोग करने के बाद, सत्र उन्हें लागू करने के लिए स्वचालित रूप से पुनः लोड हो जाता है।
