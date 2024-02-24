sp9 = {
  matches = {
    {
      { "media.class", "matches", "*/Sink" },
      { "node.name", "=", "alsa_output.pci-0000_00_1f.3.analog-stereo" }
    }
  },
  filter_chain = '/etc/surface-audio/graph.json',
  hide_parent = true
}
table.insert(dsp_policy.policy.rules, sp9)
