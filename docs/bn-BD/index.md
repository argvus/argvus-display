---
title: প্রদর্শন
description: মনিটর এবং লেআউট কনফিগার করুন।
---

`argvus-display` সরবরাহ করে এবং Hyprland-এর সাথে সংরক্ষিত লেআউটগুলিকে ইন্টিগ্রেট করে। অবস্থার অবস্থা পরীক্ষা করুন:

```sh
argvus displayctl --status
argvus displayctl --list-modes <monitor>
argvus displayctl --apply
argvus displayctl --settings
```

। হেলপারটি /docs/reference/configuration-files/ এবং  --set <monitor> <key> <value>  `argvus displayctl`  `--set <monitor> <key> <value>` `--apply-nwg`-ও সমর্থন করে। জেনারেট করা মনিটর ওভাররাইডগুলি ARGVUS কনফিগারেশন অবস্থার অংশ; দেখুন [কনফিগারেশন ফাইল](/docs/reference/configuration-files/)।

কন্ট্রোল সেন্টারে **ডিসপ্লে** খুলুন বা একটি মনিটর খুঁজুন। পাওয়া যাওয়া সেটিংস ক্ষমতার উপর নির্ভর করে এবং এর মধ্যে রেজোলিউশন, রিফ্রেশ রেট, স্কেল, অবস্থান, অভিমুখ, প্রধান ডিসপ্লে, VRR এবং HDR অন্তর্ভুক্ত থাকতে পারে। শুধুমাত্র মনিটরের মডেল একটি সাধারণ তালিকায় থাকায় একটি সেটিং সমর্থিত হিসাবে প্রদর্শিত হয় না; এটি রিপোর্ট করার জন্য সক্রিয় কম্পোজিটর এবং মনিটর ব্যাকএন্ড থাকা উচিত।

ডিসপ্লে লেআউট প্রয়োগ করা চলমান Hyprland মনিটর কনফিগারেশন পরিবর্তন করে এবং পরে সেশনের জন্য সমর্থিত লেআউট স্টেট সংরক্ষণ করে। উপলব্ধ থাকলে পৃষ্ঠার প্রয়োগ/প্রত্যাহার প্রক্রিয়া ব্যবহার করুন। যদি কোনো মনিটর ব্যবহারযোগ্য না থাকে, ডিসপ্লে পৃষ্ঠায় ফিরে যান অথবা জেনারেট করা ফাইল সম্পাদনার পরিবর্তে সংরক্ষিত স্টেটের সাথে `argvus displayctl --apply` ব্যবহার করুন।

## কমান্ড-লাইন ডিসপ্লে ব্যবস্থাপনা

গ্রাফিক্যাল ইন্টারফেস ব্যবহার না করে ডিসপ্লে সেটিংস জিজ্ঞাসা এবং পরিবর্তন করতে `argvus displayctl` ব্যবহার করুন:

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

মনিটর নামগুলি  eDP-1  DP-2  HDMI-1  `--status`  `HDMI-1`  `DP-2`  `eDP-1` `--settings` দ্বারা প্রদর্শিত হয় (সাধারণত ল্যাপটপের জন্য --settings, --settings, --settings ইত্যাদি)। GUI ব্যবহার করে পরিবর্তন করার জন্য --settings ব্যবহার করার পর, সেসনগুলি স্বয়ংক্রিয়ভাবে সেগুলি প্রয়োগ করতে পুনরায় লোড হয়।
