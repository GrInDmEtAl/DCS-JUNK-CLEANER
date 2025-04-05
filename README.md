# DCS Junk Cleaner

## Créditos

- **Créditos para:** [chrisneal72](https://github.com/chrisneal72/DCS-removeJunk-Scripts)
- **All Credits:** [chrisneal72/DCS-removeJunk-Scripts](https://github.com/chrisneal72/DCS-removeJunk-Scripts) – Criador das mudanças iniciais

## V3 Notes – DCS_Junk_Cleaner_V3.lua

### Português
O script `DCS_Junk_Cleaner_V3.lua` é uma versão aprimorada que dispensa as etapas anteriores. Basta carregá-lo diretamente e configurar o tempo inicial e o intervalo de execução.  
```
Tempo até a primeira limpeza (segundos)
delay = 5,

Intervalo para repetição da limpeza em segundos (ex: 600 para 10 min). Coloque 'nil' para executar apenas uma vez.
repeatInterval = 60,
```

**Exemplo:**
![Exemplo V3](https://github.com/user-attachments/assets/0a2d7d6f-7166-422c-a2dc-b02e6b1b80b0)

**Log de Saída:**  
![Log Output](https://github.com/user-attachments/assets/7dac6058-cdcb-4311-8a84-0548f741b965)

---

## Descrição

### Português
Em resumo, este script limpa as carcaças (junk) do cenário ou mapa destruído, com o objetivo de otimizar o desempenho tanto do servidor quanto do cliente.  
O script é acionado por um trigger configurado com o valor ME 1200 (equivalente a 20 minutos). A cada 20 minutos, ele executa a validação de todo o mapa e, após um atraso de 10 segundos, remove todos os resíduos, crateras e detritos do cenário.

**Requisitos:**
- **MIST:** [MissionScriptingTools - mist_4_5_128.lua](https://github.com/mrSkortch/MissionScriptingTools/blob/development/mist_4_5_128.lua)
- Para limpeza por zonas, utilize o script original: [1_RemoveJunkInZones.lua](https://github.com/chrisneal72/DCS-removeJunk-Scripts/blob/main/1_RemoveJunkInZones.lua)
