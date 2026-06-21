"""Paleta de cores vibrante usada para identificar cada disciplina visualmente."""

SUBJECT_PALETTE = [
    "#FF6B6B",  # vermelho coral
    "#4D96FF",  # azul vibrante
    "#FFD93D",  # amarelo
    "#6BCB77",  # verde
    "#A66CFF",  # roxo
    "#FF922E",  # laranja
    "#3DD9D6",  # turquesa
    "#FF6FB5",  # rosa
    "#5C7AEA",  # índigo
    "#C9E265",  # verde-limão
]


def subject_color(subject):
    """Retorna uma cor estável da paleta para a disciplina, baseada no seu id."""
    if not subject:
        return SUBJECT_PALETTE[0]
    subject_id = subject.get('id') if isinstance(subject, dict) else subject
    if subject_id is None:
        return SUBJECT_PALETTE[0]
    return SUBJECT_PALETTE[int(subject_id) % len(SUBJECT_PALETTE)]


def subject_color_by_id(subject_id, subjects):
    """Busca a disciplina pelo id numa lista e retorna sua cor."""
    subject = next((s for s in subjects if s.get('id') == subject_id), None)
    return subject_color(subject) if subject else SUBJECT_PALETTE[0]
