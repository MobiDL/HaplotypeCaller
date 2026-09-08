# MobiDL HaplotypeCaller

**WDL workflow for HaplotypeCaller variant calling in capture-based panel sequencing.**

---

## 📌 Overview

WDL workflow for HaplotypeCaller variant calling in capture-based panel sequencing.
It is designed to be modular, reproducible, and optimized for use in clinical settings.

---

## 🛠️ Requirements

### Software Dependencies

- [WDL](https://openwdl.org/) (Workflow Description Language)
- [Cromwell](https://cromwell.readthedocs.io/) (Workflow Execution Engine)
- [Apptainer](https://apptainer.org/) (for containerized tools)

### Inputs

- **Sam/Bam/Cram file(s)**
- **Reference genome** (e.g., GRCh38)
- **Target regions** (BED file for panel definition)

---

## 🚀 Quick Start

### 1. Clone the Repository

```bash
git clone https://github.com/MobiDL/HaplotypeCaller.git
cd alignmentSR
```

### 2. Configure Inputs

Edit the `inputs.json` file to specify your input files and parameters:

```json
{
  "HaplotypeCaller.reads": ["path/to/sample1.bam", "path/to/sample2.cram"...],
  "HaplotypeCaller.reference": "path/to/reference.fa",
  "HaplotypeCaller.target_regions": "path/to/targets.bed"
}
```

### 3. Run the Workflow

```bash
cromwell run HaplotypeCaller.wdl -i inputs.json
```

---

## 📂 Repository Structure

```
HaplotypeCaller/
├── backends.conf/           # Backends sub-repository
├── modules/                 # Modules sub-repository
├── tests/                   # tests directory containing minimal dataset
├── HaplotypeCaller.wdl      # Main workflow file
└── README.md                # This file
```

---

## ⚙️ Workflow Steps

<img height="840" alt="HaplotypeCaller" src="https://github.com/user-attachments/assets/6e864de5-bbba-4003-9cb1-981fd4b643aa" />

---

## 📊 Outputs

- **VCF files**: Variant Calling Format file(s)

---

## 🤝 Contributing

Contributions are welcome! Please open an issue or submit a pull request for any improvements or bug fixes.

---

## 🆘 Support

For questions or issues, please contact the Mobidic team or open an issue in this repository.
