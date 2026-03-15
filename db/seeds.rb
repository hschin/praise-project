# This file should ensure the existence of records required to run the application in every environment (production,
# development, test). The code here should be idempotent so that it can be executed at any point in every environment.
# The data can then be loaded with the bin/rails db:seed command (or created alongside the database with db:setup).

songs_data = [
  {
    title: "奇异恩典",
    artist: "传统圣诗",
    default_key: "G",
    lyrics: [
      { section_type: "verse", position: 1,
        content: "奇异恩典何等甘甜\n我罪已得赦免\n前我失丧今被寻回\n瞎眼今得看见",
        pinyin: "Qíyì ēndiǎn hé děng gāntián\nWǒ zuì yǐ dé shèmiǎn\nQián wǒ shī wáng jīn bèi xún huí\nXiā yǎn jīn dé kànjiàn" },
      { section_type: "verse", position: 2,
        content: "如此恩典教我敬畏\n恩典使我释然\n最初信主那一时刻\n恩典已叫我得见",
        pinyin: "Rúcǐ ēndiǎn jiào wǒ jìngwèi\nĒndiǎn shǐ wǒ shìrán\nZuì chū xìn zhǔ nà yī shíkè\nĒndiǎn yǐ jiào wǒ dé jiàn" },
      { section_type: "verse", position: 3,
        content: "我们在世万载之久\n如同刚过一天\n赞美天父诗歌不断\n直到永永远远",
        pinyin: "Wǒmen zài shì wàn zǎi zhī jiǔ\nRútóng gāng guò yī tiān\nZànměi tiānfù shīgē bùduàn\nZhídào yǒngyǒng yuǎnyuǎn" }
    ]
  },
  {
    title: "你是我的力量",
    artist: "赞美之泉",
    default_key: "C",
    lyrics: [
      { section_type: "verse", position: 1,
        content: "你是我力量 我心所爱\n靠着你得胜 每一天\n你是我盼望 我的诗歌\n在患难中 你是我的倚靠",
        pinyin: "Nǐ shì wǒ lìliàng wǒ xīn suǒ ài\nKào zhe nǐ déshèng měi yī tiān\nNǐ shì wǒ pànwàng wǒ de shīgē\nZài huànnàn zhōng nǐ shì wǒ de yǐkào" },
      { section_type: "chorus", position: 2,
        content: "哦 主你是我力量\n你是我力量\n在软弱中 你使我刚强\n哦 主你是我力量",
        pinyin: "Ō zhǔ nǐ shì wǒ lìliàng\nNǐ shì wǒ lìliàng\nZài ruǎnruò zhōng nǐ shǐ wǒ gāngqiáng\nŌ zhǔ nǐ shì wǒ lìliàng" }
    ]
  },
  {
    title: "主你是我",
    artist: "赞美之泉",
    default_key: "G",
    lyrics: [
      { section_type: "verse", position: 1,
        content: "主你是我 藏身之处\n主你是我 生命之泉\n我愿亲近你 信靠你\n因你爱我 到永远",
        pinyin: "Zhǔ nǐ shì wǒ cáng shēn zhī chù\nZhǔ nǐ shì wǒ shēngmìng zhī quán\nWǒ yuàn qīnjìn nǐ xìnkào nǐ\nYīn nǐ ài wǒ dào yǒngyuǎn" },
      { section_type: "chorus", position: 2,
        content: "哦 主我爱你\n我要一生跟随你\n哦 主我爱你\n我要一生赞美你",
        pinyin: "Ō zhǔ wǒ ài nǐ\nWǒ yào yīshēng gēnsuí nǐ\nŌ zhǔ wǒ ài nǐ\nWǒ yào yīshēng zànměi nǐ" }
    ]
  },
  {
    title: "哈利路亚颂",
    artist: "传统圣诗",
    default_key: "D",
    lyrics: [
      { section_type: "verse", position: 1,
        content: "赞美耶和华 万民都当赞美他\n赞美我神 万国都当颂扬他\n因他的慈爱 大过于诸天\n他的诚实 达到云端",
        pinyin: "Zànměi Yēhéhuá wàn mín dōu dāng zànměi tā\nZànměi wǒ shén wànguó dōu dāng sòngyáng tā\nYīn tā de cíài dàguò yú zhū tiān\nTā de chéngshí dádào yún duān" },
      { section_type: "chorus", position: 2,
        content: "哈利路亚 哈利路亚\n哈利路亚 哈利路亚\n哈利路亚 哈利路亚\n哈利路亚",
        pinyin: "Hā lì lù yǎ hā lì lù yǎ\nHā lì lù yǎ hā lì lù yǎ\nHā lì lù yǎ hā lì lù yǎ\nHā lì lù yǎ" }
    ]
  },
  {
    title: "因他名",
    artist: "赞美之泉",
    default_key: "A",
    lyrics: [
      { section_type: "verse", position: 1,
        content: "因他名 我们聚集\n因他名 我们敬拜\n因他名 我们同心合意\n荣耀归给他",
        pinyin: "Yīn tā míng wǒmen jùjí\nYīn tā míng wǒmen jìngbài\nYīn tā míng wǒmen tóngxīn héyì\nRóngyào guī gěi tā" },
      { section_type: "chorus", position: 2,
        content: "耶稣 耶稣\n你是配得荣耀尊贵的主\n耶稣 耶稣\n万王之王 永远的神",
        pinyin: "Yēsū yēsū\nNǐ shì pèi dé róngyào zūnguì de zhǔ\nYēsū yēsū\nWàn wáng zhī wáng yǒngyuǎn de shén" }
    ]
  },
  {
    title: "我心所爱",
    artist: "普世赞美团",
    default_key: "E",
    lyrics: [
      { section_type: "verse", position: 1,
        content: "我心所爱 高过一切\n超越所有 名字之上\n我要高举 你的名\n直到永远",
        pinyin: "Wǒ xīn suǒ ài gāo guò yīqiè\nChāoyuè suǒyǒu míngzì zhī shàng\nWǒ yào gāojǔ nǐ de míng\nZhídào yǒngyuǎn" },
      { section_type: "chorus", position: 2,
        content: "你配得 我所有赞美\n你配得 我所有敬拜\n因你爱我 舍命的爱\n我永远爱你主",
        pinyin: "Nǐ pèi dé wǒ suǒyǒu zànměi\nNǐ pèi dé wǒ suǒyǒu jìngbài\nYīn nǐ ài wǒ shě mìng de ài\nWǒ yǒngyuǎn ài nǐ zhǔ" }
    ]
  }
]

songs_data.each do |attrs|
  lyrics_attrs = attrs.delete(:lyrics)
  song = Song.find_or_initialize_by(title: attrs[:title])
  song.assign_attributes(attrs.merge(import_status: "done"))
  if song.save
    if song.lyrics.none?
      lyrics_attrs.each { |l| song.lyrics.create!(l) }
    end
    puts "✓ #{song.title}"
  else
    puts "✗ #{song.title}: #{song.errors.full_messages.join(', ')}"
  end
end

puts "\nDone — #{songs_data.length} songs seeded."
